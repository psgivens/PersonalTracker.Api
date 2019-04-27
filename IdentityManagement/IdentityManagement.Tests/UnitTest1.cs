using NUnit.Framework;

namespace Tests
{
    public class Tests
    {
        [SetUp]
        public void Setup()
        {
        }

        [Test]
        public void Test1()
        {
            Assert.Pass();
        }

        [Test]
        public void Test2()
        {
            Assert.Pass();
        }

        [TestCase(0)]
        public void DoTest3(int i)
        {
          Assert.AreEqual(i, 0);
        }
    }
}
