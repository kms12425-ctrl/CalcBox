import localUnitTest from './LocalUnit.test';
import expressionTest from './Expression.test';
import toolsTest from './Tools.test';

export default function testsuite() {
  localUnitTest();
  expressionTest();
  toolsTest();
}
