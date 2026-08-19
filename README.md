# Ace Sign Studio

Desktop apps for **Snyder's Ace Hardware (store #12180, Media, PA)** that turn a SKU into a
print-ready, Ace-branded shelf sign. Type an item's SKU and the app pulls the **store-specific
price** and the **product photo** from acehardware.com, lays out a branded **5½ × 3½ in** sign
(other sizes, a Sale format, and a STIHL Clearance format included), and prints it — single, or a whole **batch queue**
gang-run to fit multiple signs per sheet and save paper.

There are two native apps that share the same lookup and the same brand-compliant output:

| Platform | Folder | Download |
|---|---|---|
| **macOS** (Apple Silicon) | [`AceSignStudio/`](AceSignStudio/) | [**AceSignStudio-macOS.zip**](https://github.com/codysuter/ace-sign-studio/releases/download/ace-sign-studio-macos/AceSignStudio-macOS.zip) |
| **Windows** (10/11) | [`AceSignStudioWindows/`](AceSignStudioWindows/) | [**AceSignStudio.exe**](https://github.com/codysuter/ace-sign-studio/releases/download/ace-sign-studio-windows/AceSignStudio.exe) |

> The download links serve the latest build. Both apps are built automatically on GitHub's
> macOS/Windows runners (see `.github/workflows/`), so a fresh binary is published on every change.

## Installing the downloads

**Windows:** download `AceSignStudio.exe` and double-click. On first launch, Windows SmartScreen
may warn about an unrecognized app (it's unsigned) — click **More info → Run anyway** (once).

**macOS:** download and unzip `AceSignStudio-macOS.zip`, move **Ace Sign Studio.app** to your
Applications folder. Because it isn't signed with a paid Apple Developer account, the first launch
needs one of: right-click the app → **Open** → **Open**, or run once in Terminal:
`xattr -cr "/Applications/Ace Sign Studio.app"`.

## Using it

1. Type an item's **SKU** (or product name, or a pasted acehardware.com product URL) and press Enter.
2. The app opens the product on acehardware.com, reads the **name and photo**, and calls Ace's
   store-price API (`purchaseLocation=12180`) for **your store's price**, including the sale price.
3. Everything lands in editable fields; the preview updates live.
4. **Print** or **Export PDF** — or **Add to Queue** and batch several signs, gang-run to save paper.

Everything the lookup fills in stays editable. A numeric SKU only ever returns the product with that
exact item number — it never substitutes a different item (so the sign can't get the wrong price).

## Building from source (optional)

The downloads above are prebuilt, but you can build locally:

- **macOS:** `cd AceSignStudio && ./Scripts/build-app.sh` (needs macOS 13+ and the Command Line
  Tools), or open `Package.swift` in Xcode.
- **Windows:** double-click `AceSignStudioWindows/build-exe.bat` (needs Python 3.10+), or run
  `run-from-source.bat`.

See each app's own README (`AceSignStudio/README.md`, `AceSignStudioWindows/README.md`) for details.

## Brand compliance

Follows the Ace Brand Guidelines: **Ace Red PMS 186 C**, the **Roboto** brand font, the official
**Sale pricepoint** (black SALE tag, white price on a red chip with superscript cents, black REG.
chip), and the official two-line Ace logo.

## STIHL Clearance signs

A dedicated **STIHL Clearance** format for a cleared-out floor unit — loud enough to stop someone in
the aisle, and honest about what a clearance STIHL is:

- A black **STIHL CLEARANCE** banner with an Ace-red **THIS UNIT ONLY** tab, inside a red frame.
- Optional **was / now pricing** — the old price struck through, the new one in the Ace pricepoint,
  and what the customer saves.
- A **BEFORE YOU BUY** block carrying the store's terms on every copy: the price is good on that one
  unit, the mechanic has gone through it and it starts and runs, STIHL's original warranty still
  covers mechanical issues but not cosmetic ones, and clearance STIHL sales are final.

The terms are baked into the app rather than typed per sign, so a clearance machine can never go out
with the wrong ones. This format prints no product photo — the terms block needs the room, and a
catalog photo isn't the unit on the floor.
