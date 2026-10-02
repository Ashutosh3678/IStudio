'use strict';

const assert = require('node:assert/strict');
const { describe, it } = require('node:test');
const request = require('supertest');

process.env.JWT_SECRET = 'test-secret-security-suite-32chars!!';
process.env.NODE_ENV = 'test';

const memoryUsers = require('../src/store/memoryUsers');
memoryUsers.enabled = true;
const { app } = require('../src/server');

describe('Public data deletion request page', () => {
  it('serves an accessible request form', async () => {
    const response = await request(app).get('/delete-data');

    assert.equal(response.status, 200);
    assert.match(response.headers['content-type'], /text\/html/);
    assert.match(response.text, /name="email"/);
    assert.match(response.text, /name="phone"/);
    assert.match(response.text, /does not immediately delete an account/i);
  });

  it('accepts a valid request without revealing whether an account exists', async () => {
    const response = await request(app)
      .post('/delete-data')
      .type('form')
      .send({ email: 'person@example.com', phone: '+91 98765-43210' });

    assert.equal(response.status, 200);
    assert.match(response.text, /Request received/);
    assert.doesNotMatch(response.text, /person@example\.com|9876543210/);
  });

  it('rejects malformed email or phone details', async () => {
    const response = await request(app)
      .post('/delete-data')
      .type('form')
      .send({ email: 'invalid', phone: '123' });

    assert.equal(response.status, 400);
    assert.match(response.text, /Enter a valid account email address/);
  });
});