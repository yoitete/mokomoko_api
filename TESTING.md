# Testing Guide

## Backend Tests (Rails API)

### Setup

```bash
cd mokomoko_api
docker-compose exec api bundle install
docker-compose exec api rails db:test:prepare
```

### Running Tests

```bash
# Run all tests
docker-compose exec api bundle exec rspec

# Run specific test file
docker-compose exec api bundle exec rspec spec/requests/authentication_spec.rb

# Run tests with coverage
docker-compose exec api bundle exec rspec --format documentation

# Run tests in watch mode
docker-compose exec api bundle exec rspec --watch
```

### Test Categories

- **Authentication Tests**: `spec/requests/authentication_spec.rb`
- **Posts API Tests**: `spec/requests/posts_spec.rb`
- **Users API Tests**: `spec/requests/users_spec.rb`
- **Model Tests**: `spec/models/`

## Frontend Tests (Next.js)

### Setup

```bash
cd mokomoko_front
npm install
```

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

### Test Categories

- **Component Tests**: `__tests__/components/`
- **Hook Tests**: `__tests__/hooks/`

## Test Coverage Goals

- **Backend**: >90% coverage for controllers and models
- **Frontend**: >80% coverage for components and hooks

## Writing New Tests

### Backend Test Structure

```ruby
RSpec.describe "ResourceName", type: :request do
  describe "GET /endpoint" do
    it "returns expected response" do
      # Test implementation
    end
  end
end
```

### Frontend Test Structure

```typescript
describe("ComponentName", () => {
  it("renders correctly", () => {
    // Test implementation
  });
});
```

## Continuous Integration

Tests should be run automatically on:

- Pull request creation
- Push to main branch
- Before deployment
