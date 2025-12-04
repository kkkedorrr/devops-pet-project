import unittest
from app import app

class BasicTests(unittest.TestCase):
    def setUp(self):
        # Create a test client
        self.app = app.test_client()
        self.app.testing = True

    def test_home_status_code(self):
        # Send a GET request to /
        result = self.app.get('/')
        # Assert the status code is 200 (OK)
        self.assertEqual(result.status_code, 200)

if __name__ == "__main__":
    unittest.main()
