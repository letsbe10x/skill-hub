---
purpose: Font pairing recommendations by mood, industry fit, and Google Fonts import
lookup-by: Mood / Industry
---

# Font Pairings Reference

Use during Step 3 to select typography. Each pairing includes display+body fonts,
the mood/personality they convey, best-fit industries, and a Google Fonts import URL.

| # | Display / Heading | Body / UI | Mood | Best For | Google Fonts Import |
|---|-------------------|-----------|------|----------|---------------------|
| 1 | Inter | Inter | Clean, neutral, universal | SaaS, dashboards, developer tools | `https://fonts.google.com/share?selection.family=Inter:wght@400;500;600;700` |
| 2 | Clash Display | Inter | Bold, modern, confident | Agencies, startups, Gen Z brands | `https://fonts.google.com/share?selection.family=Inter:wght@400;500` (Clash via CDN) |
| 3 | Cormorant Garamond | Montserrat | Elegant, calming, sophisticated | Luxury, wellness, beauty, spa, editorial | `https://fonts.google.com/share?selection.family=Cormorant+Garamond:wght@400;600&family=Montserrat:wght@400;500;600` |
| 4 | Playfair Display | Lato | Classic, editorial, warm | Restaurant, hospitality, lifestyle, news | `https://fonts.google.com/share?selection.family=Playfair+Display:wght@400;700&family=Lato:wght@400;700` |
| 5 | DM Serif Display | DM Sans | Contemporary, approachable | Modern SaaS, fintech, productivity | `https://fonts.google.com/share?selection.family=DM+Serif+Display&family=DM+Sans:wght@400;500;600` |
| 6 | Space Grotesk | Space Mono | Technical, crypto, futuristic | Web3, developer tools, crypto, tech | `https://fonts.google.com/share?selection.family=Space+Grotesk:wght@400;600;700&family=Space+Mono` |
| 7 | Nunito | Nunito | Friendly, rounded, approachable | EdTech, children's apps, wellness, community | `https://fonts.google.com/share?selection.family=Nunito:wght@400;600;700;800` |
| 8 | Fraunces | Jost | Earthy, organic, editorial | Sustainability, food, wellness, creative | `https://fonts.google.com/share?selection.family=Fraunces:wght@400;700&family=Jost:wght@400;500` |
| 9 | IBM Plex Serif | IBM Plex Sans | Trustworthy, corporate, structured | Finance, banking, enterprise, government | `https://fonts.google.com/share?selection.family=IBM+Plex+Serif:wght@400;700&family=IBM+Plex+Sans:wght@400;500;600` |
| 10 | Raleway | Open Sans | Clean, professional, neutral | Healthcare, legal, nonprofit, general SaaS | `https://fonts.google.com/share?selection.family=Raleway:wght@400;600;700&family=Open+Sans:wght@400;600` |
| 11 | Poppins | Poppins | Geometric, modern, versatile | Startups, e-commerce, mobile apps | `https://fonts.google.com/share?selection.family=Poppins:wght@400;500;600;700` |
| 12 | Merriweather | Source Sans 3 | Readable, trustworthy, editorial | Blogs, news, nonprofit, documentation | `https://fonts.google.com/share?selection.family=Merriweather:wght@400;700&family=Source+Sans+3:wght@400;600` |
| 13 | Lora | Nunito Sans | Warm, literary, personal | Lifestyle blogs, portfolio, personal brand | `https://fonts.google.com/share?selection.family=Lora:wght@400;600&family=Nunito+Sans:wght@400;600` |
| 14 | Bebas Neue | Roboto | Strong, athletic, bold | Sports, gaming, fitness, events | `https://fonts.google.com/share?selection.family=Bebas+Neue&family=Roboto:wght@400;500` |
| 15 | Josefin Sans | Josefin Sans | Geometric, minimal, fashion-forward | Fashion, beauty, architecture | `https://fonts.google.com/share?selection.family=Josefin+Sans:wght@300;400;600;700` |
| 16 | Cinzel | Crimson Pro | Classical, luxury, prestigious | Legal, academic, high-end retail | `https://fonts.google.com/share?selection.family=Cinzel:wght@400;700&family=Crimson+Pro:wght@400;600` |
| 17 | Syne | Syne | Expressive, artistic, unique | Creative portfolios, music, art | `https://fonts.google.com/share?selection.family=Syne:wght@400;700;800` |
| 18 | Geist | Geist Mono | Developer-forward, clean | AI products, dev tools, code editors | Via Vercel CDN |
| 19 | Plus Jakarta Sans | Plus Jakarta Sans | Modern, balanced | General SaaS, marketing, fintech | `https://fonts.google.com/share?selection.family=Plus+Jakarta+Sans:wght@400;500;600;700` |
| 20 | Bricolage Grotesque | Inter | Expressive, contemporary | Creative agencies, modern brand, editorial | `https://fonts.google.com/share?selection.family=Bricolage+Grotesque:wght@400;600;700&family=Inter:wght@400;500` |

## Typography Scale (Standard)

Use as default unless the direction calls for a custom scale:

```
Display:  clamp(2.5rem, 5vw, 4rem)   — hero headline
H1:       clamp(2rem, 4vw, 3rem)
H2:       clamp(1.5rem, 3vw, 2.25rem)
H3:       1.5rem
Body:     1rem (16px base)
Small:    0.875rem
Label:    0.75rem — uppercase tracking 0.05em
```

Line heights: Display 1.1 | Headings 1.2-1.3 | Body 1.5-1.6 | UI labels 1.4

## Font Loading Best Practice

```html
<!-- Preconnect for Google Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<!-- Then the actual stylesheet link from the Google Fonts Import URL above -->
```

Limit to 2 font families. Each family: max 3 weights for performance.
