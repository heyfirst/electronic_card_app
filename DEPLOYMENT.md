# Auto Deployment Setup

This project is configured for automatic deployment to Fly.io using GitHub Actions.

## 🚀 How Auto Deployment Works

- **Trigger**: Every push to `main` branch
- **Platform**: GitHub Actions + Fly.io
- **Build**: Flutter web app with release build
- **Deploy**: Automatic deployment to https://ben-mae-the-wedding.fly.dev

## 🔧 Setup Instructions

### 1. Run the setup script:

```bash
./setup-auto-deploy.sh
```

### 2. Manual setup (alternative):

1. **Get your Fly.io API token:**

    ```bash
    flyctl auth token
    ```

2. **Add to GitHub repository secrets:**
    - Go to your GitHub repository
    - Settings > Secrets and variables > Actions
    - New repository secret:
        - Name: `FLY_API_TOKEN`
        - Value: [your fly.io token]

3. **Push to main branch:**
    ```bash
    git add .
    git commit -m "Add auto deployment"
    git push origin main
    ```

## 📊 Workflows

### 1. **CI Pipeline** (`ci.yml`)

- Runs on every PR and push
- Code analysis, formatting check
- Run tests with coverage
- Test build

### 2. **Deploy Pipeline** (`deploy.yml`)

- Runs only on push to `main`
- Full Flutter web build
- Deploy to Fly.io
- Deployment notifications

## 🔄 Development Workflow

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes and commit
3. Push and create PR: `git push origin feature/my-feature`
4. CI will run automatically on PR
5. After review, merge to `main`
6. Auto deployment triggers automatically!

## 🛠️ Manual Deployment (Backup)

If you need to deploy manually:

```bash
./deploy.sh
```

## 📱 Monitoring

- **GitHub Actions**: Check workflow runs in Actions tab
- **Fly.io Dashboard**: Monitor app status at fly.io/dashboard
- **App URL**: https://ben-mae-the-wedding.fly.dev
