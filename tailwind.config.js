/** @type {import('tailwindcss').Config} */
module.exports = {
    // In Tailwind v4, config is primarily done via CSS (@theme), but keeping
    // this file helps with safelisting and portability. It is safe to include.
    darkMode: 'class',
    content: [
        './app/views/**/*.{erb,html,html.erb}',
        './app/helpers/**/*.rb',
        './app/assets/**/*.{erb,html,html.erb,css,js}',
        './app/javascript/**/*.{js,ts,jsx,tsx}',
        './app/controllers/**/*.rb'
    ],
    theme: {
        container: {
            center: true,
            // Align with our layout container used across the app
            screens: {
                sm: '40rem',  // 640px
                md: '48rem',  // 768px
                lg: '64rem',  // 1024px
                xl: '80rem',  // 1280px
                '2xl': '96rem' // 1536px
            },
            padding: {
                DEFAULT: '1rem',
                md: '1.5rem',
            }
        },
        extend: {
            // Add customizations here if needed later
        }
    },
    safelist: [
        // Specific utilities used conditionally or that can be missed by scanners
        'font-semibold',
        'text-slate-900',
        'bg-white/70',
        'bg-white/80',
        'backdrop-blur',
        'animate-ping',
        // Conservative palette safelist for slate/red variants we use
        { pattern: /^(bg|text|border|hover:text|hover:bg|focus:ring)-(slate|red)-(50|100|200|300|400|500|600|700|900)$/ },
    ],
    plugins: []
};
