# Converting npm projects to pnpm

pnpm has better security and disk space efficiency, here's how to convert your npm projects to pnpm:

## Step-by-step conversion:
1. Remove npm-specific files (in each project directory):

```bash
rm -rf node_modules
rm package-lock.json  # npm's lockfile
```

2. Install dependencies with pnpm:

```bash
pnpm install  # This reads package.json and creates pnpm-lock.yaml
```

3. **Update your scripts** (if you have any npm-specific commands):
   - Change `npm run <script>` to `pnpm run <script>` or just `pnpm <script>`
   - Change `npm install <package>` to `pnpm add <package>`
   - Change `npm install -g <package>` to `pnpm add -g <package>`

4. **Batch conversion script** (automates steps 1-2 for multiple projects):

   If you have many projects to convert, this script will automatically convert all npm projects in subdirectories. Save this as `convert_to_pnpm.sh` and run it in your projects parent directory (e.g., if you have `~/projects/app1/`, `~/projects/app2/`, etc., run it from `~/projects/`):

```bash
#!/bin/bash
for dir in */; do
  if [ -f "$dir/package.json" ]; then
    echo "Converting $dir to pnpm..."
    cd "$dir"
    rm -rf node_modules package-lock.json
    pnpm install
    cd ..
  fi
done
```

   **What it does:**
   - Loops through all subdirectories
   - Checks if each directory contains a `package.json` (indicating it's a Node.js project)
   - Removes `node_modules` and `package-lock.json` 
   - Runs `pnpm install` to reinstall dependencies with pnpm
   - Creates `pnpm-lock.yaml` for each project

   **Why use it:** Saves time when converting multiple projects instead of doing steps 1-2 manually for each one.

5. **Remove global npm packages** (optional):

```bash
npm list -g --depth=0  # See what's installed globally
npm uninstall -g <package-name>  # Remove specific packages
pnpm add -g <package-name>  # Reinstall with pnpm
```

## Benefits you'll get:

- **Disk space**: pnpm uses a content-addressable store (saves ~30-50% space)
- **Security**: Stricter dependency resolution, no phantom dependencies
- **Speed**: Faster installs due to linking rather than copying

## Important notes:

- Your `package.json` stays the same - only the lockfile and node_modules structure changes!
- Add `pnpm-lock.yaml` to your git repository (remove `package-lock.json` if present)
- Consider adding `.npmrc` with `auto-install-peers=true` for automatic peer dependency installation
