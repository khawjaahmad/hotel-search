#!/usr/bin/env node

const fs = require('fs');
const { execSync } = require('child_process');

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

function testAllureSetup() {
  log('🧪 Testing Allure Setup for Hotel Booking App', COLORS.BLUE);

  // Check Node.js
  try {
    const nodeVersion = execSync('node --version', { encoding: 'utf8' }).trim();
    log(`✅ Node.js: ${nodeVersion}`, COLORS.GREEN);
  } catch (error) {
    log('❌ Node.js not found', COLORS.RED);
    return false;
  }

  // Check npm and uuid package
  try {
    require('uuid');
    log('✅ UUID package available', COLORS.GREEN);
  } catch (error) {
    log('⚠️ UUID package not found - installing...', COLORS.YELLOW);
    try {
      execSync('npm install uuid', { stdio: 'inherit' });
      log('✅ UUID package installed', COLORS.GREEN);
    } catch (installError) {
      log('❌ Failed to install UUID package', COLORS.RED);
      return false;
    }
  }

  // Check Allure CLI
  try {
    const allureVersion = execSync('allure --version', { encoding: 'utf8' }).trim();
    log(`✅ Allure CLI: ${allureVersion}`, COLORS.GREEN);
  } catch (error) {
    log('❌ Allure CLI not found', COLORS.RED);
    log('💡 Install with: npm install -g allure-commandline', COLORS.BLUE);
    return false;
  }

  // Check directories
  const dirs = ['allure-results', 'allure-report', 'scripts'];
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
      log(`📁 Created directory: ${dir}`, COLORS.BLUE);
    } else {
      log(`✅ Directory exists: ${dir}`, COLORS.GREEN);
    }
  }

  // Test basic Allure result creation
  try {
    const { v4: uuidv4 } = require('uuid');
    const testResult = {
      uuid: uuidv4(),
      name: 'Setup Test',
      status: 'passed',
      stage: 'finished',
      start: Date.now(),
      stop: Date.now() + 1000,
      labels: [
        { name: 'framework', value: 'patrol' },
        { name: 'testType', value: 'setup' }
      ],
      links: [],
      parameters: [],
      attachments: []
    };

    fs.writeFileSync('allure-results/setup-test-result.json', JSON.stringify(testResult, null, 2));
    log('✅ Test Allure result created successfully', COLORS.GREEN);
  } catch (error) {
    log(`❌ Failed to create test Allure result: ${error.message}`, COLORS.RED);
    return false;
  }

  // Test Allure report generation
  try {
    execSync('allure generate allure-results -o allure-report --clean', { stdio: 'inherit' });
    log('✅ Allure report generated successfully', COLORS.GREEN);
  } catch (error) {
    log(`❌ Failed to generate Allure report: ${error.message}`, COLORS.RED);
    return false;
  }

  log('🎉 Allure setup test completed successfully!', COLORS.GREEN);
  log('💡 You can now run: make overview-allure', COLORS.BLUE);

  return true;
}

if (require.main === module) {
  testAllureSetup();
}