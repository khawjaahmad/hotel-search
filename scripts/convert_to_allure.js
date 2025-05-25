const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const testResultsPath = 'test_results.json';
const allureResultsDir = 'allure-results';

if (!fs.existsSync(testResultsPath)) {
    console.error('❌ Test results file not found:', testResultsPath);
    process.exit(1);
}

if (!fs.existsSync(allureResultsDir)) {
    fs.mkdirSync(allureResultsDir, { recursive: true });
}

const testResults = fs.readFileSync(testResultsPath, 'utf8')
    .split('\n')
    .filter(line => line.trim())
    .map(line => {
        try {
            return JSON.parse(line);
        } catch (e) {
            return null;
        }
    })
    .filter(result => result !== null);

const testCases = new Map();
let totalTests = 0, passedTests = 0, failedTests = 0;

testResults.forEach(event => {
    if (event.type === 'testStart') {
        const testCase = {
            name: event.test.name,
            uuid: uuidv4(),
            fullName: event.test.name,
            labels: [
                { name: 'suite', value: event.test.name.split(' ')[0] }
            ],
            status: 'unknown',
            start: Date.now()
        };
        testCases.set(event.test.id, testCase);
    }
    
    if (event.type === 'testDone') {
        const testCase = testCases.get(event.testID);
        if (testCase) {
            testCase.stop = Date.now();
            totalTests++;
            
            if (event.result === 'success') {
                testCase.status = 'passed';
                passedTests++;
            } else {
                testCase.status = 'failed';
                failedTests++;
                testCase.statusDetails = {
                    message: event.error || 'Test failed',
                    trace: event.stackTrace || ''
                };
            }
            
            const resultPath = path.join(allureResultsDir, `${testCase.uuid}-result.json`);
            fs.writeFileSync(resultPath, JSON.stringify(testCase, null, 2));
        }
    }
});

console.log(`✅ Total: ${totalTests}, Passed: ${passedTests}, Failed: ${failedTests}`);
fs.unlinkSync(testResultsPath);
