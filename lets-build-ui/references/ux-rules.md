---
purpose: Prioritized UX rules with named citations — apply by priority during Step 3 and evidence gate
lookup-by: Category / Priority
---

# UX Rules Reference (99 Rules)

Apply **Accessibility**, **Interaction**, **Performance**, and **Responsive** rules on every UI task. Apply remaining categories when the relevant surface is in scope.

## Accessibility (CRITICAL — apply always)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 36 | Color Contrast | All | Minimum 4.5:1 ratio for normal text | Low contrast text (#999 on white = 2.8:1) | High |
| 37 | Color Only | All | Use icons/text in addition to color | Red/green only for error/success | High |
| 38 | Alt Text | All | Descriptive alt text for meaningful images | Empty or missing alt attributes | High |
| 39 | Heading Hierarchy | Web | Use sequential heading levels h1→h6 | Skip heading levels or misuse for styling | Medium |
| 40 | ARIA Labels | All | Add aria-label for icon-only buttons | Icon buttons without labels | High |
| 41 | Keyboard Navigation | Web | Tab order matches visual order; all functionality keyboard accessible | Keyboard traps or illogical tab order | High |
| 42 | Screen Reader | All | Use semantic HTML and ARIA properly | Div soup with no semantics | Medium |
| 43 | Form Labels | All | Use label with for attribute or wrap input | Placeholder-only inputs | High |
| 44 | Error Messages | All | Use aria-live or role=alert for errors | Visual-only error indication | High |
| 45 | Skip Links | Web | Provide skip to main content link | No skip link on nav-heavy pages | Medium |
| 99 | Motion Sensitivity | All | Respect prefers-reduced-motion; wrap in @media query | Force scroll effects / parallax | High |

## Touch & Interaction (CRITICAL — apply always)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 22 | Touch Target Size | Mobile | Minimum 44×44px touch targets | Tiny clickable areas (w-6 h-6 buttons) | High |
| 23 | Touch Spacing | Mobile | Minimum 8px gap between touch targets | Tightly packed clickable elements | Medium |
| 24 | Gesture Conflicts | Mobile | Avoid horizontal swipe on main content | Override system gestures | Medium |
| 25 | Tap Delay | Mobile | Use touch-action: manipulation | Default mobile tap handling (300ms delay) | Medium |
| 28 | Focus States | All | Visible focus rings on all interactive elements (focus:ring-2) | Remove focus outline without replacement | High |
| 29 | Hover States | Web | Change cursor and add subtle visual change (hover:bg-gray-100 cursor-pointer) | No hover feedback on clickable elements | Medium |
| 30 | Active States | All | Add pressed/active state (active:scale-95) | No feedback during interaction | Medium |
| 31 | Disabled States | All | Reduce opacity and change cursor (opacity-50 cursor-not-allowed) | Disabled same style as enabled | Medium |
| 32 | Loading Buttons | All | Disable button and show loading state during async | Allow multiple clicks during processing | High |
| 35 | Confirmation Dialogs | All | Confirm before delete/irreversible actions | Delete without confirmation | High |

## Animation (apply always)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 7 | Excessive Motion | All | Animate 1-2 key elements per view maximum | Animate everything that moves | High |
| 8 | Duration Timing | All | Use 150–300ms for micro-interactions | Animations longer than 500ms for UI | Medium |
| 9 | Reduced Motion | All | Check prefers-reduced-motion media query | Ignore accessibility motion settings | High |
| 10 | Loading States | All | Use skeleton screens or spinners | Leave UI frozen with no feedback | High |
| 11 | Hover vs Tap | All | Use click/tap for primary interactions | Rely only on hover for important actions | High |
| 12 | Continuous Animation | All | Use for loading indicators only | Decorative elements with animate-bounce | Medium |
| 13 | Transform Performance | Web | Use transform and opacity for animations | Animate width/height/top/left properties | Medium |
| 14 | Easing Functions | All | Use ease-out for entering, ease-in for exiting | Linear for UI transitions | Low |

## Layout (apply always)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 15 | Z-Index Management | Web | Define z-index scale system (10, 20, 30, 50) | Arbitrary large z-index values (z-[9999]) | High |
| 19 | Content Jumping | Web | Reserve space for async content (aspect-ratio or fixed height) | Let images/content push layout | High |
| 20 | Viewport Units | Web | Use dvh or account for mobile browser chrome | Use 100vh for full-screen mobile layouts | Medium |
| 21 | Container Width | Web | Limit max-width for text content (65-75ch / max-w-prose) | Let text span full viewport width | Medium |

## Performance (apply always)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 46 | Image Optimization | All | Use appropriate size and format (WebP/AVIF); srcset | Unoptimized full-size images | High |
| 47 | Lazy Loading | All | Lazy load below-fold images (loading="lazy") | Load everything upfront | Medium |
| 48 | Code Splitting | Web | Split code by route/feature (dynamic import) | Single large bundle | Medium |
| 50 | Font Loading | Web | Use font-display: swap | FOIT (Flash of Invisible Text) | Medium |
| 53 | Render Blocking | Web | Inline critical CSS, defer non-critical | Large blocking CSS files | Medium |

## Responsive (apply always)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 64 | Mobile First | Web | Start with mobile styles, add breakpoints (min-width) | Desktop-first causing mobile issues | Medium |
| 65 | Breakpoint Testing | Web | Test at 375, 768, 1024, 1440px | Only test on your device | Medium |
| 66 | Touch Friendly | Web | Increase touch targets on mobile | Same tiny buttons on mobile | High |
| 67 | Readable Font Size | All | Minimum 16px body text on mobile | text-xs for body text | High |
| 68 | Viewport Meta | Web | width=device-width, initial-scale=1 | Missing or incorrect viewport | High |
| 69 | Horizontal Scroll | Web | Ensure content fits viewport (max-w-full overflow-x-hidden) | Content wider than viewport | High |
| 71 | Table Handling | Web | Horizontal scroll or card layout for tables | Wide tables breaking layout | Medium |

## Navigation (apply when nav is in scope)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 1 | Smooth Scroll | Web | scroll-behavior: smooth on html element | Jump directly without transition | High |
| 2 | Sticky Navigation | Web | Add padding-top to body equal to nav height | Let nav overlap first section content | Medium |
| 3 | Active State | All | Highlight active nav item with color/underline | No visual feedback on current location | Medium |
| 4 | Back Button | Mobile | Preserve navigation history properly | Break browser/app back button behavior | High |
| 5 | Deep Linking | All | Update URL on state/view changes | Static URLs for dynamic content | Medium |
| 6 | Breadcrumbs | Web | Use for sites with 3+ levels of depth | Use for flat single-level sites | Low |

## Forms (apply when forms are in scope)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 54 | Input Labels | All | Always show label above or beside input | Placeholder as only label | High |
| 55 | Error Placement | All | Show error below related input | Single error message at top of form | Medium |
| 56 | Inline Validation | All | Validate on blur for most fields | Validate only on submit | Medium |
| 57 | Input Types | All | Use email, tel, number, url input types | Text input for everything | Medium |
| 58 | Autofill Support | Web | Use autocomplete attribute properly | autocomplete="off" everywhere | Medium |
| 59 | Required Indicators | All | Use asterisk or (required) text | No indication of required fields | Medium |
| 60 | Password Visibility | All | Toggle to show/hide password | Password always hidden | Medium |
| 61 | Submit Feedback | All | Show loading then success/error state | No feedback after submit | High |
| 63 | Mobile Keyboards | Mobile | Use inputmode attribute for correct keyboard | Default keyboard for all inputs | Medium |

## Typography (apply when typography is in scope)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 72 | Line Height | All | Use 1.5–1.75 for body text (leading-relaxed) | Cramped leading-none (1) | Medium |
| 73 | Line Length | Web | Limit to 65-75 characters per line (max-w-prose) | Full-width text on large screens | Medium |
| 74 | Font Size Scale | All | Use consistent modular scale (12 14 16 18 24 32) | Arbitrary font sizes | Medium |
| 76 | Contrast Readability | All | Use darker text on light backgrounds (text-gray-900) | Gray text on gray background | High |
| 77 | Heading Clarity | All | Clear size/weight difference from body | Headings similar to body text | Medium |

## Feedback (apply when async operations or user actions exist)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 78 | Loading Indicators | All | Show spinner/skeleton for operations > 300ms | Frozen UI | High |
| 79 | Empty States | All | Helpful message and action ("No items yet. Create one!") | Blank empty screens | Medium |
| 80 | Error Recovery | All | Provide clear next steps (Try again + help link) | Error message only | Medium |
| 81 | Progress Indicators | All | Step indicators or progress bar for multi-step | No indication of progress | Medium |
| 82 | Toast Notifications | All | Auto-dismiss after 3–5 seconds | Toasts that never disappear | Medium |
| 83 | Confirmation Messages | All | Brief success message on completed action | Silent success | Medium |

## AI Interaction (apply when AI features exist)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 92 | Disclaimer | All | Clearly label AI-generated content (AI Assistant label) | Present AI as human without label | High |
| 93 | Streaming | All | Stream text response token by token (typewriter effect) | Spinner until 100% complete for 10s+ | Medium |
| 98 | Feedback Loop | All | Thumbs up/down or "Regenerate" on AI outputs | Static read-only output | Low |

## Sustainability (apply for new products)

| # | Issue | Platform | Do | Don't | Severity |
|---|-------|----------|-----|-------|---------|
| 96 | Auto-Play Video | Web | Click-to-play; pause when off-screen | Auto-play high-res video loops | Medium |
| 97 | Asset Weight | Web | Compress and lazy load 3D models (Draco compression) | Load 50MB textures | Medium |
