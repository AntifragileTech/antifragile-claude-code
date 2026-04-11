#!/usr/bin/env node
import { config } from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load .env from workspace root (boston/) BEFORE dynamic imports
config({ path: join(__dirname, '..', '..', '..', '..', '.env') });

// Dynamic imports so env vars are available when modules initialize
const { researchCompany, discoverCompetitors } = await import('./research.js');
const { generateQueries } = await import('./query-gen.js');
const { runEngines } = await import('./engines.js');
const { analyzeResults } = await import('./analyzer.js');
const { generateReport } = await import('./reporter.js');
const ROOT = join(__dirname, '..');
const WORKSPACE_ROOT = join(ROOT, '..', '..', '..');

function getClientDir(clientName) {
  return join(WORKSPACE_ROOT, 'clients', clientName, 'aeo-visibility-reports');
}

const commands = {
  async profile(clientName, options = {}) {
    console.log(`\n🔍 Profiling: ${clientName}\n`);

    const clientDir = getClientDir(clientName);
    if (!existsSync(clientDir)) {
      mkdirSync(clientDir, { recursive: true });
    }

    // Research company
    console.log('📊 Researching company...');
    const companyProfile = await researchCompany(clientName, options.url);
    
    // Discover competitors
    console.log('🎯 Discovering competitors...');
    const competitors = await discoverCompetitors(companyProfile);
    
    const profile = {
      company: companyProfile,
      competitors,
      createdAt: new Date().toISOString()
    };
    
    const profilePath = join(clientDir, 'profile.json');
    writeFileSync(profilePath, JSON.stringify(profile, null, 2));
    console.log(`✅ Profile saved: ${profilePath}`);
    
    // Generate queries
    console.log('\n🤖 Generating search queries...');
    const queries = await generateQueries(profile);
    
    const queriesPath = join(clientDir, 'queries.json');
    writeFileSync(queriesPath, JSON.stringify(queries, null, 2));
    console.log(`✅ Generated ${queries.length} queries: ${queriesPath}`);
    
    console.log('\n📝 Review and edit queries.json, then run:');
    console.log(`   node src/cli.js run ${clientName}\n`);
  },

  async run(clientName, options = {}) {
    const clientDir = getClientDir(clientName);
    
    if (!existsSync(clientDir)) {
      throw new Error(`Client not found. Run: node src/cli.js profile ${clientName}`);
    }

    // Load profile and queries
    const profile = JSON.parse(readFileSync(join(clientDir, 'profile.json'), 'utf8'));
    const allQueries = JSON.parse(readFileSync(join(clientDir, 'queries.json'), 'utf8'));
    
    // Use custom queries if provided, otherwise all
    const queries = options.queries || allQueries;
    
    console.log(`\n🚀 Running AEO visibility check for: ${clientName}`);
    console.log(`📊 Queries: ${queries.length}`);
    console.log(`🔎 Engines: ChatGPT, Claude, Gemini, Perplexity`);
    console.log(`💰 Estimated cost: $${(queries.length * 4 * 0.05).toFixed(2)} - $${(queries.length * 4 * 0.15).toFixed(2)}\n`);
    
    // Create run directory
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
    const runDir = join(clientDir, 'runs', timestamp);
    mkdirSync(runDir, { recursive: true });
    
    // Run queries against all engines
    console.log('⏳ Running queries (this may take a while)...\n');
    const responses = await runEngines(queries, {
      onProgress: (engine, idx, total) => {
        console.log(`  ${engine}: ${idx + 1}/${total} queries`);
      }
    });
    console.log('\n');
    
    // Save raw responses
    const rawPath = join(runDir, 'raw-responses.json');
    writeFileSync(rawPath, JSON.stringify(responses, null, 2));
    console.log(`✅ Raw responses saved: ${rawPath}`);
    
    // Analyze results
    console.log('\n🔬 Analyzing results...');
    const analysis = await analyzeResults(responses, profile);
    
    // Generate report
    console.log('📄 Generating reports...');
    await generateReport(analysis, profile, runDir);
    
    // Update history
    const historyPath = join(clientDir, 'history.csv');
    const historyRow = [
      timestamp,
      queries.length,
      analysis.summary.totalMentions,
      analysis.summary.avgVisibilityScore,
      analysis.summary.topEngine,
      `runs/${timestamp}/report.md`
    ].join(',');
    
    if (!existsSync(historyPath)) {
      writeFileSync(historyPath, 'timestamp,queries,mentions,avg_score,top_engine,report\n');
    }
    writeFileSync(historyPath, readFileSync(historyPath, 'utf8') + historyRow + '\n');
    
    console.log(`\n✅ Run complete!`);
    console.log(`📊 Report: ${join(runDir, 'report.md')}`);
    console.log(`📈 CSV: ${join(runDir, 'results.csv')}`);
    console.log(`📜 History: ${historyPath}\n`);
  },

  async history(clientName) {
    const clientDir = getClientDir(clientName);
    const historyPath = join(clientDir, 'history.csv');
    
    if (!existsSync(historyPath)) {
      console.log(`No history for ${clientName}`);
      return;
    }
    
    console.log('\n📜 Historical runs:\n');
    console.log(readFileSync(historyPath, 'utf8'));
  }
};

// Parse CLI args
const [,, command, ...args] = process.argv;

if (!command || !commands[command]) {
  console.log(`
AEO Visibility Checker

Commands:
  profile <client-name> [--url=...]     Research company and generate queries
  run <client-name> [--queries="q1" "q2" ...]    Run visibility check
  history <client-name>                 Show historical runs

Examples:
  node src/cli.js profile acme-corp
  node src/cli.js run acme-corp
  node src/cli.js run acme-corp --queries "best AI tools" "top LLMs"
  node src/cli.js history acme-corp
  `);
  process.exit(1);
}

// Parse options
const options = {};
const positional = [];
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--queries') {
    if (!options.queries) options.queries = [];
    // Collect all following non-flag args as queries
    while (i + 1 < args.length && !args[i + 1].startsWith('--')) {
      i++;
      options.queries.push(args[i]);
    }
  } else if (args[i].startsWith('--')) {
    const [key, ...valueParts] = args[i].slice(2).split('=');
    options[key] = valueParts.length > 0 ? valueParts.join('=') : true;
  } else {
    positional.push(args[i]);
  }
}

commands[command](...positional, options).catch(err => {
  console.error('\n❌ Error:', err.message);
  process.exit(1);
});
