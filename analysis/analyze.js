const fs = require('fs');

const yargs = require('yargs');
const { BigQuery } = require('@google-cloud/bigquery');

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function getOrCreateDataset(bigquery, datasetName) {
  console.log(`Ensuring dataset ${bigquery.projectId}.${datasetName} exists.`);

  const [dataset] = await bigquery
    .dataset(datasetName, {
      location: 'US'
    })
    .get({
      autoCreate: true
    });

  return dataset;
}

async function createTableFromQuery(bigquery, dataset, query) {
  const sql = query.sql;
  const destination = dataset.table(query.destination);

  console.log(`Creating table ${bigquery.projectId}.${dataset.id}.${destination.id} from query.`);

  try {
    const [job] = await bigquery.createQueryJob({
      query: sql,
      destination,
      location: 'US'
      // writeDisposition: 'WRITE_TRUNCATE', // forced overwrite, default is WRITE_EMPTY
    });

    let jobFinished = false;
    while (!jobFinished) {
      await sleep(1 * 1000);
      const [metadata] = await job.getMetadata();
      const { status: jobStatus } = metadata;
      if (jobStatus.errors) {
        throw new Error(jobStatus.errors[0].message);
      }
      console.log(`Checking status of job ${metadata.id}: ${jobStatus.state}`);
      jobFinished = jobStatus.state === 'DONE';
    }
  } catch (err) {
    if (err.errors[0].reason !== 'duplicate') throw err;
  }

  return destination.get();
}

function readQueryTemplates() {
  const queryFiles = fs.readdirSync(`${__dirname}/queries`);

  return queryFiles.map(filename => {
    const id = filename.split('-')[0];

    const queryFile = fs.readFileSync(`${__dirname}/queries/${filename}`, { encoding: 'utf8' });

    const sql = queryFile
      .split(/\n/)
      .filter(line => !line.startsWith('--'))
      .join('\n');

    const description = queryFile
      .split(/\n/)
      .filter(line => line !== '--' && line.startsWith('--') && !line.startsWith('-- Destination'))
      .join('\n');

    const destination = queryFile.match(/Destination: (\w+)/)[1];

    return {
      id,
      filename,
      sql,
      description,
      destination
    };
  });
}

function parameterizeQueries(queryTemplates, project, dataset, full) {
  return queryTemplates.map(({ sql, ...query }) => ({
    sql: sql
      .replace(/\{\{DATASET\}\}/g, `${project}.${dataset}`)
      .replace(/\{\{FILES_TABLE\}\}/g, full ? 'files' : 'sample_files')
      .replace(/\{\{CONTENTS_TABLE\}\}/g, full ? 'contents' : 'sample_contents'),
    ...query
  }));
}

function printQuery(query) {
  console.log('-- ============================================================================');
  console.log(`-- File: ${query.filename}`);
  console.log(`-- Destination: ${query.destination}`);
  console.log('');
  console.log(query.description);
  console.log('');
  console.log(query.sql);
  console.log('');
}

function findQuery(queries, id) {
  return queries.find(query => query.id === id);
}

async function main() {
  const queryTemplates = readQueryTemplates();

  const availableQueries = queryTemplates.map(query => `  ${query.filename}`).join('\n');
  const availableQueryIds = ['all'].concat(queryTemplates.map(query => query.id));

  const argv = yargs
    .usage('Usage: node $0 [options]')
    .example('node $0 -p PROJECT -d DATASET -q all -m print', 'print all queries')
    .example('node $0 -p PROJECT -d DATASET -q 01 -m execute', 'execute the first query')

    .alias('p', 'project')
    .describe('p', 'Google Cloud Project where the BigQuery result dataset is located')

    .alias('d', 'dataset')
    .describe('d', 'BigQuery Dataset name for the results')

    .alias('q', 'query')
    .string('q')
    .describe('q', 'Select a query by index')
    .choices('q', availableQueryIds)

    .alias('f', 'full')
    .boolean('f')
    .describe(
      'f',
      'Run on full GitHub dataset, not on sample. WARNING: This may cost up to USD 20 per query!'
    )

    .alias('m', 'mode')
    .describe('m', 'Whether to "print" or "execute" the query')
    .choices('m', ['print', 'execute'])

    .demandOption(['p', 'd', 'm', 'q'])

    .help('h')
    .alias('h', 'help')
    .epilog(`Available Queries:\n${availableQueries}`).argv;

  const bigquery = new BigQuery({
    projectId: argv.project
  });

  const queries = parameterizeQueries(queryTemplates, argv.project, argv.dataset, argv.full);

  if (argv.mode === 'print') {
    if (argv.query === 'all') {
      queries.forEach(printQuery);
      return;
    }

    printQuery(findQuery(queries, argv.query));
    return;
  }

  if (argv.mode === 'execute') {
    const dataset = await getOrCreateDataset(bigquery, argv.dataset);

    if (argv.query === 'all') {
      for (let query of queries) {
        await createTableFromQuery(bigquery, dataset, query);
      }
      return;
    }

    const query = findQuery(queries, argv.query);
    await createTableFromQuery(bigquery, dataset, query);
    return;
  }
}

main();
