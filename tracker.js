const { spawn, execSync } = require('child_process');
const fs = require('fs');

function updateGithub(newUrl) {
  // 1. Update the JSON file
  fs.writeFileSync('server.json', JSON.stringify({ url: newUrl }, null, 2));
  
  // 2. Push to GitHub
  try {
    console.log('🔄 Pushing new URL to GitHub...');
    execSync('git add server.json');
    execSync('git commit -m "Auto-update Jellyfin URL"');
    execSync('git push');
    console.log('✅ Successfully updated GitHub Pages! (Give it 1-2 mins to go live)');
  } catch (err) {
    console.log('⚠️ Git skipped (URL likely hasn\'t changed).');
  }
}

function startTunnel() {
  console.log('🚀 Starting Cloudflare tunnel...');
  
  const tunnel = spawn('cloudflared', ['tunnel', '--url', 'http://localhost:8096'], { shell: true });

  // Watch standard error (where cloudflared usually prints its logs)
  tunnel.stderr.on('data', (data) => {
    const text = data.toString();
    
    // Print everything cloudflared says so we can debug!
    console.log(`[CLOUDFLARED] ${text.trim()}`);
    
    const match = text.match(/https:\/\/[a-zA-Z0-9-]+\.trycloudflare\.com/);
    if (match) {
      const url = match[0];
      console.log(`\n🔗 Caught new URL: ${url}`);
      updateGithub(url);
    }
  });

  // Watch standard output just in case
  tunnel.stdout.on('data', (data) => {
    console.log(`[CLOUDFLARED LOG] ${data.toString().trim()}`);
  });

  tunnel.on('close', (code) => {
    console.log(`\n⚠️ Tunnel crashed or closed (Code ${code}). Restarting in 5 seconds...`);
    setTimeout(startTunnel, 5000);
  });
}

// Kick it off
startTunnel();