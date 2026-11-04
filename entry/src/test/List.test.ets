import localUnitTest from './LocalUnit.test';
import expressionTest from './Expression.test';

export default function testsuite() {
  localUnitTest();
  expressionTest();
}
