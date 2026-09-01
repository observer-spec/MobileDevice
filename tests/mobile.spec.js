const { test, expect } = require('@playwright/test');

test('renders a mobile layout', async ({ page }) => {
  await page.goto('<!doctype html><meta name="viewport" content="width=device-width"><main><h1>MobileDevice</h1><button>Run test</button></main>');
  await expect(page.getByRole('heading', { name: 'MobileDevice' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Run test' })).toBeVisible();
  expect(page.viewportSize().width).toBeLessThan(500);
});
