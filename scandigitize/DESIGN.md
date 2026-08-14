---
name: ScanDigitize
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#444653'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#757684'
  outline-variant: '#c4c5d5'
  surface-tint: '#3755c3'
  primary: '#00288e'
  on-primary: '#ffffff'
  primary-container: '#1e40af'
  on-primary-container: '#a8b8ff'
  inverse-primary: '#b8c4ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#611e00'
  on-tertiary: '#ffffff'
  tertiary-container: '#872d00'
  on-tertiary-container: '#ffa583'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde1ff'
  primary-fixed-dim: '#b8c4ff'
  on-primary-fixed: '#001453'
  on-primary-fixed-variant: '#173bab'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#ffdbce'
  tertiary-fixed-dim: '#ffb59a'
  on-tertiary-fixed: '#380d00'
  on-tertiary-fixed-variant: '#802a00'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
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
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  container-padding-mobile: 16px
  container-padding-desktop: 32px
  gutter: 16px
  density-high: 8px
  density-medium: 16px
  density-low: 24px
---

## Brand & Style

This design system is built for high-stakes enterprise and government document management. The brand personality is rooted in **reliability, efficiency, and data-density**. It prioritizes clarity and speed of information processing over decorative flair.

The design style is **Corporate Modern**, characterized by:
- **Systematic Structure:** Strict adherence to a grid for managing complex data.
- **Functional Clarity:** High information density without visual clutter.
- **Professionalism:** A neutral, calm environment that minimizes cognitive load during long periods of operation.
- **Utility-First:** Every element serves a specific purpose in the document digitization lifecycle.

## Colors

The palette is anchored by **Enterprise Blue**, communicating authority and stability.
- **Primary:** Used for main actions, active states, and branding.
- **Slate (Secondary):** Used for navigation, auxiliary icons, and secondary text.
- **Background:** A very light gray-blue (#F8FAFC) reduces eye strain compared to pure white while providing enough contrast for white surface cards.
- **Semantic Colors:** Emerald (Success), Amber (Warning), and Rose (Danger) are used for status badges, alerts, and data visualization. These should be paired with low-opacity background tints (10-15%) for UI labels to ensure legibility.

## Typography

The design system utilizes **Inter** for its exceptional legibility in data-heavy environments. 
- **Body-md (14px)** is the workhorse size for all tables and document metadata.
- **Body-sm (13px)** is used for dense sidebars and supporting information.
- **Labels** utilize a slightly heavier weight and, in some cases, all-caps styling to differentiate field names from user-entered data.
- **Headlines** use a tighter letter-spacing to maintain a professional, cohesive look at larger sizes.

## Layout & Spacing

This design system uses a **Fluid Grid** model with high-density presets.
- **Desktop (Admin & Scanning):** 12-column grid. Uses `density-high` (8px/12px) for data tables and document queues to maximize visible information.
- **Mobile (Dashboard):** 4-column grid. Switches to `density-medium` (16px) for charts and summary cards to ensure touch-target safety.
- **Margins:** 32px on desktop to provide visual breathing room around dense containers; 16px on mobile.
- **Data Tables:** Horizontal scrolling is preferred over column hiding for critical document metadata.

## Elevation & Depth

To maintain a crisp, professional look, the system uses **Tonal Layers** and **Low-Contrast Outlines** rather than heavy shadows.
- **Level 0 (Background):** #F8FAFC. Used for the main canvas.
- **Level 1 (Surface):** White (#FFFFFF) with a 1px border (#E2E8F0). Used for primary content cards and data tables.
- **Level 2 (Interaction):** A soft, diffused shadow (0px 4px 6px -1px rgba(0, 0, 0, 0.1)) applied only to hovering elements or active modals.
- **Level 3 (Overlays):** Used for dropdowns and context menus to ensure they pop against the underlying data.

## Shapes

The design system uses a **Soft (0.25rem)** roundedness.
- **Standard UI (Buttons, Inputs, Small Cards):** 4px (0.25rem) radius. This provides a modern touch without sacrificing the professional, "engineered" feel of the interface.
- **Large Containers (Sections, Main Workspace):** 8px (0.5rem) radius for a slightly softer boundary between major application areas.
- **Badges/Status Tags:** 2px or fully square to differentiate them from interactive buttons.

## Components

### Buttons
- **Primary:** Solid Enterprise Blue with white text.
- **Secondary:** Outline Slate with #64748B text.
- **Ghost:** No border, primary text. Used for less frequent actions within tables.

### Data Tables
- **Header:** Slate-50 background, 12px Semi-bold text, 1px bottom border.
- **Rows:** 48px height for high density, 1px bottom border, subtle hover state (Blue-50).
- **Cells:** Vertical alignment centered, primary text color.

### Status Badges
- Small text, uppercase, bold. Uses 10% opacity background of the semantic color (e.g., Emerald-100 background with Emerald-700 text).

### Input Fields
- White background, 1px Slate-200 border. 
- Focus state: Primary Blue 1px border with a 2px blue glow (ring).
- Labels are positioned above the field in 12px Semi-bold Slate.

### Cards
- White background, 1px border, no shadow by default. 
- Headers include a 1px bottom border to separate titles from content.

### Scanning Queue
- A specialized list component with a thumbnail preview (left), progress bar (center), and action icons (right).