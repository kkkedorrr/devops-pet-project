import unittest
# Import 'flask_app' instead of 'app'
from app.app import flask_app 

class BasicTests(unittest.TestCase):
    def setUp(self):
        # Update usage here
        self.app = flask_app.test_client()
        self.app.testing = True

    def test_home_status_code(self):
        result = self.app.get('/')
        self.assertEqual(result.status_code, 200)

if __name__ == "__main__":
    unittest.main()
    