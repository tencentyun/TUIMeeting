import { defineConfig } from 'vite';
import uni from '@dcloudio/vite-plugin-uni';

import path from 'path';

function resolve(dir) {
  return path.join(__dirname, dir);
}

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  const isProd = mode === 'production';

  const commonConfig = {
    plugins: [
      uni(),
    ],
    resolve: {
      alias: {
        '@': resolve('src'),
        '@TUIRoom': resolve('src/roomkit/TUIRoom'),
      },
    },
    build: {
    },
  };
  const devConfig = {
    ...commonConfig,
  };

  const prodConfig = {
    ...commonConfig,
  };

  return isProd ? prodConfig : devConfig;
});
