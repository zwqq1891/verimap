---
name: Authenticity & Precision
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#414754'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#727785'
  outline-variant: '#c1c6d6'
  surface-tint: '#005bc0'
  primary: '#005bbf'
  on-primary: '#ffffff'
  primary-container: '#1a73e8'
  on-primary-container: '#ffffff'
  inverse-primary: '#adc7ff'
  secondary: '#5e5e62'
  on-secondary: '#ffffff'
  secondary-container: '#e3e2e6'
  on-secondary-container: '#646468'
  tertiary: '#bb1712'
  on-tertiary: '#ffffff'
  tertiary-container: '#df3429'
  on-tertiary-container: '#ffffff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc7ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004493'
  secondary-fixed: '#e3e2e6'
  secondary-fixed-dim: '#c7c6ca'
  on-secondary-fixed: '#1a1b1e'
  on-secondary-fixed-variant: '#46474a'
  tertiary-fixed: '#ffdad5'
  tertiary-fixed-dim: '#ffb4a9'
  on-tertiary-fixed: '#410001'
  on-tertiary-fixed-variant: '#930004'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-lg:
    fontFamily: Manrope
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
  max-width: 1280px
---

## Brand & Style

The design system is engineered to project an aura of high-tech authority and analytical precision. Aimed at users who value truth and transparency in digital reviews, the UI balances the familiarity of established tech ecosystems with the sophisticated "edge" of modern artificial intelligence.

The aesthetic leans heavily into **Corporate Modernism**, drawing specific influence from Material 3 principles. It prioritizes clarity through generous whitespace, high-contrast typography, and a refined "light-washed" color palette. The emotional response should be one of calm confidence—the interface does not shout; it reveals insights through structured data and subtle visual cues. Every element is designed with high affordance to ensure the user feels in control of the underlying AI engine.

## Colors

The color palette centers on professional reliability and immediate hazard recognition. 

- **Primary (Google Blue):** Used for primary actions, active states, and branding elements to establish immediate trust and platform familiarity.
- **Secondary (Slate Charcoal):** Reserved for high-level text hierarchy and structural elements to provide a grounded, professional contrast against the light surfaces.
- **Tertiary (High-Risk Crimson):** A purposeful, high-visibility red used exclusively for alerting users to low-credibility scores, potential bot activity, or fraudulent patterns.
- **Neutral (Light Gray Background):** The canvas of the application. Using #F8F9FA instead of pure white reduces eye strain during long analysis sessions and allows white card elements to "pop" via elevation.

## Typography

This design system utilizes a dual-font strategy to balance character with utility. 

**Manrope** is used for headlines and titles. Its modern, geometric construction provides a sleek "tech" feel that remains approachable and highly readable. Large display sizes use tighter letter spacing to create a compact, authoritative look.

**Inter** is the workhorse for body text, data tables, and labels. Chosen for its exceptional legibility and neutral tone, it ensures that complex review data and AI-generated explanations are easily digestible. 

For mobile devices, headline sizes scale down to maintain vertical rhythm, while body text remains consistent to ensure accessibility. All labels use a slightly higher weight (500) to distinguish them from standard body copy.

## Layout & Spacing

The layout follows a **Fixed Grid** philosophy for primary content to maintain a premium, editorial feel on larger screens, while adopting a fluid behavior for internal card components.

- **Grid System:** A 12-column grid is used for desktop (breakpoints at 1280px+), transitioning to 8 columns for tablets and 4 columns for mobile.
- **Rhythm:** An 8px base unit governs all spacing decisions. Consistent use of `lg` (24px) for gutters and `md` (16px) for internal card padding creates a structured, breathable interface.
- **White Space:** Generous vertical margins are applied between sections to prevent cognitive overload during data analysis. On mobile, margins are reduced to 16px to maximize the utility of the limited horizontal space.

## Elevation & Depth

Visual hierarchy is established through a combination of **Tonal Layers** and **Ambient Shadows**, strictly adhering to Material 3's elevation model.

1.  **Level 0 (Base):** The #F8F9FA background.
2.  **Level 1 (Surface):** White containers (#FFFFFF) used for secondary information, featuring a subtle 1px border (#E0E0E0) and no shadow.
3.  **Level 2 (Cards/Prominent Elements):** White containers with a soft, diffused shadow (Blur: 8px, Y-Offset: 2px, Color: 4% Black). This is the default for review analysis cards.
4.  **Level 3 (Overlay/Modals):** Elements that sit above the primary UI, using a deeper shadow (Blur: 16px, Y-Offset: 4px, Color: 8% Black) and a subtle backdrop blur (4px) to focus user attention.

Shadows should never be harsh or pure black; they are tinted with the primary blue color at extremely low opacities to maintain a cohesive, "clean tech" atmosphere.

## Shapes

The design system employs a **Rounded** shape language to soften the analytical nature of the tool and make the AI feel more user-friendly.

- **Standard Elements:** Buttons, input fields, and small cards use a 0.5rem (8px) radius.
- **Large Containers:** Dashboard widgets and main review cards use `rounded-lg` (1rem / 16px).
- **Surface Accents:** Search bars and specific "Trust Score" indicators utilize pill-shaped (full-round) corners to denote high interactivity and distinguish them from static content.

## Components

### Buttons
- **Primary:** Filled with Primary Blue (#1A73E8), white text, 8px corners. Used for the main "Analyze" action.
- **Tonal:** Light blue background (10% opacity of Primary), Primary Blue text. Used for secondary actions like "Export Data."
- **Outlined:** 1px border (#DADCE0), Secondary text. Used for tertiary actions or "Cancel."

### Review Credibility Chips
- Status indicators that use a "Traffic Light" system within the primary blue/crimson framework. High credibility uses a soft green, while high-risk flags use a Crimson (#D93025) background with 10% opacity and solid Crimson text.

### Input Fields
- Outlined style with a 1px border. On focus, the border thickens to 2px and changes to Primary Blue, accompanied by a floating label per Material 3 standards.

### Analysis Cards
- The heart of the interface. These cards use `rounded-lg` (16px) corners and Level 2 elevation. They must feature a clear "Header" area for the reviewer's name and a "Footer" area for the AI's confidence score.

### Credibility Gauge
- A custom component using a semi-circular stroke. The stroke transitions from Crimson (0%) to Primary Blue (100%), providing a quick visual read of review authenticity.