import puppeteer from 'puppeteer';
import { fileURLToPath } from 'url';
import path from 'path';
import fs from 'fs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const configs = [
  { file: 'iphone.html', width: 1284, height: 2778, prefix: 'iphone', count: 5 },
  { file: 'ipad.html',   width: 2048, height: 2732, prefix: 'ipad',   count: 5 },
];

const names = ['01-hero', '02-themes', '03-game', '04-pass', '05-gameover'];

const outDir = path.join(__dirname, 'screenshots');
fs.mkdirSync(outDir, { recursive: true });

const browser = await puppeteer.launch({
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox', '--font-render-hinting=none'],
  defaultViewport: null,
});

for (const { file, width, height, prefix, count } of configs) {
  console.log(`\n📱 Generating ${prefix} screenshots (${width}×${height})...`);
  const url = `file://${path.join(__dirname, file)}`;

  for (let i = 1; i <= count; i++) {
    const page = await browser.newPage();
    await page.setViewport({ width, height, deviceScaleFactor: 1 });

    // Load the page at slide #i
    await page.goto(`${url}#${i}`, { waitUntil: 'networkidle0', timeout: 15000 });

    // Wait for fonts + deck to initialise
    await page.waitForFunction(() => {
      const stage = document.querySelector('deck-stage');
      return stage && stage.shadowRoot;
    }, { timeout: 8000 });

    // Activate the correct slide if not already (hash might not have been honoured)
    await page.evaluate((idx) => {
      const stage = document.querySelector('deck-stage');
      if (stage && typeof stage.goTo === 'function') stage.goTo(idx - 1);
    }, i);

    // Small settle time for fonts/transitions
    await new Promise(r => setTimeout(r, 800));

    // Hide the deck-stage overlay (nav controls) from the screenshot
    await page.evaluate(() => {
      const stage = document.querySelector('deck-stage');
      if (stage && stage.shadowRoot) {
        const s = document.createElement('style');
        s.textContent = '.overlay, .tapzones { display: none !important; }';
        stage.shadowRoot.appendChild(s);
      }
    });

    // Screenshot just the canvas (the slide itself, not letterboxed)
    const canvas = await page.$('.canvas');
    let screenshotTarget = canvas || page;

    const outPath = path.join(outDir, `${prefix}-${names[i - 1]}.png`);

    if (canvas) {
      await canvas.screenshot({ path: outPath, type: 'png' });
    } else {
      await page.screenshot({ path: outPath, type: 'png', clip: { x: 0, y: 0, width, height } });
    }

    const stat = fs.statSync(outPath);
    console.log(`  ✓ ${path.basename(outPath)} (${Math.round(stat.size / 1024)} KB)`);
    await page.close();
  }
}

await browser.close();
console.log('\n✅ Done! Screenshots saved to appstore/screenshots/');
