#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

// Configuration
const CONFIG = {
  INPUT_FILE: 'test-results.json',
  OUTPUT_DIR: 'integration_test/reports/allure-results',
  CATEGORIES_FILE: 'categories.json',
  ENVIRONMENT_FILE: 'environment.properties'
};

// Colors for console output
const COLORS = {
  GREEN: '\x1b[32m',
  RED: '\x1b[31m',
  YELLOW: '\x1b[33m',
  BLUE: '\x1b[34m',
  RESET: '\x1b[0m'
};

function log(message, color = COLORS.RESET) {
  console.log(`${color}${message}${COLORS.RESET}`);
}

function ensureDirectoryExists(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
    log(`📁 Created directory: ${dirPath}`, COLORS.BLUE);
  }
}

function parseTestResults(filePath) {
  if (!fs.existsSync(filePath)) {
    log(`❌ Test results file not found: ${filePath}`, COLORS.RED);
    process.exit(1);
  }

  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n').filter(line => line.trim());

  const events = [];
  for (const line of lines) {
    try {
      const event = JSON.parse(line);
      events.push(event);
    } catch (e) {
      // Skip invalid JSON lines
    }
  }

  return events;
}

function organizeTestEvents(events) {
  const tests = new Map();
  const suites = new Map();

  for (const event of events) {
    switch (event.type) {
      case 'start':
        // Test run started
        break;

      case 'group':
        suites.set(event.group.id, {
          id: event.group.id,
          name: event.group.name,
          parent: event.group.parentID || null,
          tests: []
        });
        break;

      case 'testStart':
        const test = {
          id: event.test.id,
          name: event.test.name,
          groupIDs: event.test.groupIDs || [],
          startTime: event.time || Date.now(),
          status: 'running'
        };
        tests.set(event.test.id, test);
        break;

      case 'testDone':
        const existingTest = tests.get(event.testID);
        if (existingTest) {
          existingTest.endTime = event.time || Date.now();
          existingTest.status = event.result === 'success' ? 'passed' : 'failed';
          existingTest.error = event.error;
          existingTest.stackTrace = event.stackTrace;
          existingTest.skipped = event.skipped || false;
          existingTest.hidden = event.hidden || false;
        }
        break;
    }
  }

  return { tests, suites };
}

function extractSuiteName(testName, groupIDs, suites) {
  // Try to get suite from group IDs
  if (groupIDs && groupIDs.length > 0) {
    const suite = suites.get(groupIDs[0]);
    if (suite) return suite.name;
  }

  // Extract from test name patterns
  const patterns = [
    /^(.+?)\s+Widget/i,
    /^(.+?)\s+Integration/i,
    /^(.+?)\s+Unit/i,
    /^(.+?)\s+Test/i,
    /^(.+?)\s+should/i,
    /^(.+?)\s+displays/i,
    /^(.+?)\s+loads/i
  ];

  for (const pattern of patterns) {
    const match = testName.match(pattern);
    if (match) return match[1];
  }

  // Fallback: use first few words
  const words = testName.split(' ');
  return words.slice(0, Math.min(3, words.length)).join(' ');
}

function extractFeature(testName) {
  const features = [
    { keywords: ['hotel', 'search'], feature: 'Hotel Search' },
    { keywords: ['favorite', 'heart'], feature: 'Favorites Management' },
    { keywords: ['navigation', 'tab', 'route'], feature: 'Navigation' },
    { keywords: ['overview', 'home'], feature: 'Overview' },
    { keywords: ['account', 'profile'], feature: 'Account' },
    { keywords: ['dashboard'], feature: 'Dashboard' },
    { keywords: ['widget', 'component'], feature: 'UI Components' },
    { keywords: ['integration'], feature: 'Integration' },
    { keywords: ['unit'], feature: 'Unit Tests' }
  ];

  const lowerName = testName.toLowerCase();
  for (const { keywords, feature } of features) {
    if (keywords.some(keyword => lowerName.includes(keyword))) {
      return feature;
    }
  }

  return 'General';
}

function createAllureResult(test, suites) {
  const uuid = uuidv4();
  const suiteName = extractSuiteName(test.name, test.groupIDs, suites);
  const feature = extractFeature(test.name);

  const result = {
    uuid: uuid,
    historyId: test.name.replace(/\s+/g, '_').toLowerCase(),
    name: test.name,
    fullName: test.name,
    status: test.status,
    stage: 'finished',
    start: test.startTime,
    stop: test.endTime || test.startTime,
    labels: [
      { name: 'framework', value: 'flutter_test' },
      { name: 'language', value: 'dart' },
      { name: 'suite', value: suiteName },
      { name: 'feature', value: feature },
      { name: 'severity', value: 'normal' },
      { name: 'testType', value: 'widget' }
    ],
    links: [],
    parameters: [],
    attachments: []
  };

  // Add status details for failed tests
  if (test.status === 'failed' && test.error) {
    result.statusDetails = {
      message: test.error,
      trace: test.stackTrace || ''
    };
  }

  return result;
}

function createEnvironmentProperties() {
  const env = {
    'Platform': process.platform,
    'Node.Version': process.version,
    'Test.Framework': 'Flutter Widget Tests',
    'Test.Runner': 'flutter test',
    'Execution.Date': new Date().toISOString(),
    'Project': 'Hotel Booking App',
    'Environment': 'local'
  };

  const content = Object.entries(env)
    .map(([key, value]) => `${key}=${value}`)
    .join('\n');

  return content;
}

function createCategories() {
  return [
    {
      name: 'UI Widget Tests',
      matchedStatuses: ['failed', 'broken'],
      messageRegex: '.*widget.*|.*component.*|.*ui.*'
    },
    {
      name: 'Integration Tests',
      matchedStatuses: ['failed', 'broken'],
      messageRegex: '.*integration.*|.*e2e.*'
    },
    {
      name: 'Search Functionality',
      matchedStatuses: ['failed', 'broken'],
      messageRegex: '.*search.*|.*hotel.*'
    },
    {
      name: 'Navigation Tests',
      matchedStatuses: ['failed', 'broken'],
      messageRegex: '.*navigation.*|.*route.*|.*tab.*'
    }
  ];
}

function writeAllureFiles(tests, suites, outputDir) {
  let successCount = 0;

  for (const test of tests.values()) {
    if (test.status === 'running') continue;

    try {
      const allureResult = createAllureResult(test, suites);
      const fileName = `${allureResult.uuid}-result.json`;
      const filePath = path.join(outputDir, fileName);

      fs.writeFileSync(filePath, JSON.stringify(allureResult, null, 2));
      log(`✓ Written result to ${fileName}`, COLORS.GREEN);
      successCount++;
    } catch (error) {
      log(`❌ Failed to write result for test: ${test.name}`, COLORS.RED);
    }
  }

  return successCount;
}

function main() {
  log('🚀 Enhanced Allure Test Results Converter', COLORS.BLUE);

  // Ensure output directory exists
  ensureDirectoryExists(CONFIG.OUTPUT_DIR);

  // Parse test results
  const events = parseTestResults(CONFIG.INPUT_FILE);
  log(`📊 Found ${events.length} test events`, COLORS.BLUE);

  // Organize events into tests and suites
  const { tests, suites } = organizeTestEvents(events);
  log(`🧪 Processed ${tests.size} tests in ${suites.size} suites`, COLORS.BLUE);

  // Write Allure result files
  const successCount = writeAllureFiles(tests, suites, CONFIG.OUTPUT_DIR);

  // Write environment file
  const envContent = createEnvironmentProperties();
  fs.writeFileSync(path.join(CONFIG.OUTPUT_DIR, CONFIG.ENVIRONMENT_FILE), envContent);

  // Write categories file
  const categories = createCategories();
  fs.writeFileSync(path.join(CONFIG.OUTPUT_DIR, CONFIG.CATEGORIES_FILE), JSON.stringify(categories, null, 2));

  log(`✅ Successfully converted ${successCount} test results`, COLORS.GREEN);
  log(`📁 Results written to ${CONFIG.OUTPUT_DIR}`, COLORS.BLUE);

  // Clean up
  try {
    fs.unlinkSync(CONFIG.INPUT_FILE);
  } catch (e) {
    // File might not exist
  }
}

if (require.main === module) {
  main();
}