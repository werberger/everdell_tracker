# Release Notes - v2.0.0

## 🎉 Major Release: Visual Card Selection

This is a major update introducing a completely new way to track Everdell scores!

### 🎨 Four Icon Variants Available
Choose your favorite Everdell character:
- **Teacher** (Hedgehog with book)
- **Badger** (Badger wanderer)
- **Evertree** (Ever Tree)
- **Squirrel** (Squirrel with berries)

*Same app, different icons! Each variant is a separate APK.*

### ✨ New Features

#### Visual Card Selection
- **Select cards visually** instead of entering points manually
- **Automatic score calculation** based on selected cards
- **Dynamic conditional scoring** for King, Architect, Rugwort, and more
- **Real-time score updates** as you select cards and enter additional data

#### Two Display Modes
- **Table Top (Grid)**: Organized card grid by type/color
- **Fan (Carousel)**: Beautiful hand-like fan with swipe navigation
- **Configurable in Settings**: Choose your preferred layout

#### Fan/Carousel Features
- Swipe left/right to browse cards
- 3D depth effect with card overlap
- Tap center card to select
- Filter by card type (Production, Governance, etc.)
- +/- buttons for common cards
- Count badges

#### "Your City" Section
- Shows selected cards at top of screen (both layouts)
- Horizontal scrollable list
- Quick remove by tapping cards
- Count badges for multiple copies

### 📊 Complete Card Database
- **48 base game cards** with images
- **9 expansion cards** (Extra! Extra!, Rugwort)
- Conditional scoring rules for all special cards
- Proper handling of:
  - King (events bonus)
  - Architect (resource bonus)
  - Rugwort the Ruler (other players' events)
  - Clock Tower (tokens)
  - Husband/Wife pairing
  - Wanderer (doesn't count toward city size)

### 🎮 Dynamic Scoring
- Scores recalculate instantly as you type
- King bonus updates with event changes
- Architect bonus updates with resource changes
- Rugwort bonus tracks other players' events
- No more manual calculations!

### ⚙️ Settings
- Choose between Table Top and Fan layouts
- Default scoring method (Visual, Basic, or Quick)
- All existing settings preserved

### 🎨 UI Improvements
- Modern card display with shadows and borders
- Color-coded card types
- Selection indicators
- Smooth animations
- Responsive layout

### 🔧 Technical Improvements
- Hive database for card data
- Efficient score calculation
- Proper state management
- Type-safe card models

### 📱 Per-Player Flexibility
- Each player can use different scoring methods
- Mix visual, basic, and quick entry in same game
- Switch methods mid-game

### 🐛 Bug Fixes
- Fixed city size calculations
- Corrected card type categorizations
- Improved event counting
- Better resource handling

---

## Upgrade Notes

### First Time Using Visual Selection?
1. Go to Settings → Visual Card Selection Layout
2. Choose "Table Top" or "Fan"
3. When adding a game, select "Visual" for card entry method
4. Tap "Select Cards" to browse and choose your city cards
5. Enter events, journey points, and leftover resources
6. Score calculates automatically!

### Migration
- Existing games are preserved
- Settings carry over
- No data loss

---

## What's Next?

Future updates may include:
- Visual event selection
- More expansion cards
- Card statistics
- Favorite cards
- Custom sorting options

---

**Thank you for using Everdell Tracker!** 🎴

*Full changelog: https://github.com/werberger/everdell_tracker/compare/v1.3.1...v2.0.0*
