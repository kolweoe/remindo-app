/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./**/*.html', './**/*.js'],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#6D3FA8',
          foreground: '#FFFFFF',
          container: '#8B5CF6',
          'on-container': '#0F0F0F',
        },
        secondary: {
          DEFAULT: '#D9468F',
          foreground: '#161616',
          container: '#FCE7F3',
          'on-container': '#831843',
        },
        accent: {
          DEFAULT: '#F59E0B',
          foreground: '#2D1B4E',
          container: '#FEF3C7',
          'on-container': '#78350F',
        },
        surface: {
          DEFAULT: '#F3E8FF',
          foreground: '#2D1B4E',
          container: {
            low: '#FFF8EB',
            DEFAULT: '#F7ECFF',
            high: '#E9D5FF',
          },
          nav: '#4A2E70',
          'on-nav': '#FFFFFF',
        },
        outline: {
          DEFAULT: '#4A2E70',
          variant: '#D8B4FE',
        },
        success: {
          DEFAULT: '#2E8B57',
          foreground: '#0F0F0F',
        },
        warning: {
          DEFAULT: '#D97706',
          foreground: '#2A2A2A',
        },
        error: {
          DEFAULT: '#DC2626',
          foreground: '#FFFFFF',
        },
      },
      fontFamily: {
        display: ['Boogaloo', 'cursive'],
        body: ['Capriola', 'sans-serif'],
        mono: ['Spline Sans Mono', 'monospace'],
      },
      borderRadius: {
        sm: '6px',
        DEFAULT: '12px',
        md: '14px',
        lg: '18px',
        xl: '24px',
        full: '9999px',
      },
      borderWidth: {
        2: '2px',
      },
      boxShadow: {
        pixel: '0 3px 0 #4A2E70',
        'pixel-sm': '0 2px 0 #4A2E70',
        'pixel-md': '0 3px 0 #4A2E70',
        'pixel-lg': '0 4px 0 #4A2E70',
        card: '0 4px 12px rgba(45, 27, 78, 0.12)',
      },
      spacing: {
        'unit-xs': '4px',
        'unit-sm': '8px',
        'unit-md': '12px',
        'unit-lg': '16px',
        'unit-xl': '24px',
        'page-margin': '16px',
        'nav-height': '72px',
      },
    },
  },
  plugins: [],
};
