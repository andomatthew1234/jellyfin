const { spawn, execSync } = require('child_process');
const fs = require('fs');

const frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
let spinner;

// --- Spinner Functions ---
function startLoading(msg) {
    if (spinner) clearInterval(spinner);
    let i = 0;
    spinner = setInterval(() => {
        process.stdout.write(`\r\x1b[36m${frames[i]}\x1b[0m ${msg}`);
        i = (i + 1) % frames.length;
    }, 80);
}

function stopLoading() {
    if (spinner) clearInterval(spinner);
    process.stdout.write('\r\x1b[K'); // Clears the current terminal line
}

// --- Git Functions ---
function updateGithub(newUrl) {
  stopLoading();
  
  // 1. Update the JSON file
  fs.writeFileSync('server.json', JSON.stringify({ url: newUrl }, null, 2));
  
  // 2. Push ONLY the JSON file to GitHub
  try {
    console.log('🔄 Pushing new URL to GitHub...');
    execSync('git add server.json');
    execSync('git commit -m "Auto-update Jellyfin URL"');
    execSync('git push');
    console.log('✅ Successfully updated GitHub Pages! (Give it 1-2 mins to go live)');
  } catch (err) {
    console.log('⚠️ Git skipped (URL likely hasn\'t changed).');
  }
  
  console.log(); // Blank line for spacing
  startLoading(`Tunnel active and running at ${newUrl}...`);
}

// --- Tunnel Functions ---
function startTunnel() {
  console.log('🚀 Starting Cloudflare tunnel...\n');
  startLoading('Negotiating with Cloudflare...');
  
  // Start the tunnel pointing to Jellyfin
  const tunnel = spawn('cloudflared', ['tunnel', '--url', 'http://localhost:8096'], { shell: true });

  // Watch standard error quietly in the background
  tunnel.stderr.on('data', (data) => {
    const text = data.toString();
    
    // Hunt for the random trycloudflare URL
    const match = text.match(/https:\/\/[a-zA-Z0-9-]+\.trycloudflare\.com/);
    
    if (match) {
      const url = match[0];
      stopLoading();
      console.log(`🔗 Caught new URL: ${url}`);
      updateGithub(url);
    }
  });

  tunnel.on('close', (code) => {
    stopLoading();
    console.log(`\n⚠️ Tunnel crashed or closed (Code ${code}). Restarting in 5 seconds...`);
    setTimeout(startTunnel, 5000);
  });
}

// Kick it off
startTunnel();