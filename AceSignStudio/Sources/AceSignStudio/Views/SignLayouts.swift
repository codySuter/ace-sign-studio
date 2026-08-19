import SwiftUI
import AppKit

// The sign is designed in points at its real physical size (72 pt = 1 inch).
// Every font/spacing value is multiplied by `u`, a scale unit derived from the
// sign's short side, so all layouts work at any sign size. New formats: add a
// case to SignLayoutKind and a branch here.
//
// Visual language follows the Ace Brand Guidelines: Roboto type, the primary
// palette at 100% (never tinted), and the official pricepoint formats (white
// price on a red chip, black SALE tag, black "REG." chip — guidelines p73).

/// Renders one sign at exact physical size. Used by the live preview, the
/// printer, and the PDF exporter, so what you see is exactly what prints.
struct SignRootView: View {
    let spec: SignSpec
    var isPreview = false

    var body: some View {
        Group {
            switch spec.layout {
            case .standard:
                StandardSignLayout(spec: spec, isPreview: isPreview)
            case .sale:
                SaleSignLayout(spec: spec, isPreview: isPreview)
            case .stihlClearance:
                StihlClearanceSignLayout(spec: spec, isPreview: isPreview)
            }
        }
        .frame(width: spec.sizePoints.width, height: spec.sizePoints.height)
        .background(Color.white)
        .environment(\.colorScheme, .light)
        .clipped()
    }
}

// MARK: - Standard format

struct StandardSignLayout: View {
    let spec: SignSpec
    let isPreview: Bool
    var priceStyle: PriceBlock.Style = .plain

    private var u: CGFloat { min(spec.sizePoints.width, spec.sizePoints.height) / 252 }

    var body: some View {
        if spec.isWide { wideBody } else { tallBody }
    }

    private var wideBody: some View {
        VStack(alignment: .leading, spacing: 4 * u) {
            HStack(alignment: .top, spacing: 12 * u) {
                AceBadgeView(logo: spec.customLogo, u: u)
                SignTitleBlock(spec: spec, isPreview: isPreview, u: u, lineLimit: 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .center, spacing: 12 * u) {
                ProductPhotoView(image: spec.image, showPlaceholder: isPreview, u: u)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                PriceBlock(price: spec.priceText, was: spec.wasPriceText,
                           unit: spec.unitSuffix, u: u,
                           style: priceStyle,
                           placeholderWhenEmpty: isPreview)
                    .layoutPriority(1)
            }
            .frame(maxHeight: .infinity)
            SignFooter(sku: spec.sku, footer: spec.footerText, u: u)
        }
        .padding(EdgeInsets(top: 12 * u, leading: 14 * u, bottom: 10 * u, trailing: 14 * u))
    }

    private var tallBody: some View {
        VStack(alignment: .leading, spacing: 5 * u) {
            AceBadgeView(logo: spec.customLogo, u: u)
            SignTitleBlock(spec: spec, isPreview: isPreview, u: u, lineLimit: 3)
            ProductPhotoView(image: spec.image, showPlaceholder: isPreview, u: u)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                Spacer(minLength: 0)
                PriceBlock(price: spec.priceText, was: spec.wasPriceText,
                           unit: spec.unitSuffix, u: u, alignment: .center,
                           style: priceStyle,
                           placeholderWhenEmpty: isPreview)
                Spacer(minLength: 0)
            }
            SignFooter(sku: spec.sku, footer: spec.footerText, u: u)
        }
        .padding(EdgeInsets(top: 12 * u, leading: 14 * u, bottom: 10 * u, trailing: 14 * u))
    }
}

// MARK: - Sale format
// Same structure as Standard, with the official promo pricepoint treatment.

struct SaleSignLayout: View {
    let spec: SignSpec
    let isPreview: Bool

    var body: some View {
        StandardSignLayout(spec: spec, isPreview: isPreview, priceStyle: .salePoint)
    }
}

// MARK: - STIHL Clearance format
//
// A loud, single-unit sign for a cleared-out STIHL machine. Two jobs at once:
// stop someone in the aisle, and tell them plainly what a clearance STIHL is
// and isn't — the terms differ enough from a normal sale that they belong on
// the sign, not on a separate placard that can wander off.
//
// Deliberately photo-free. At shelf-card sizes the terms block needs the room,
// and a catalog photo on a one-off floor unit shows a machine that isn't the
// one the customer is standing in front of.

struct StihlClearanceSignLayout: View {
    let spec: SignSpec
    let isPreview: Bool

    private var u: CGFloat { min(spec.sizePoints.width, spec.sizePoints.height) / 252 }
    private var frameWidth: CGFloat { 5 * u }

    var body: some View {
        VStack(spacing: 0) {
            ClearanceBanner(u: u)
            VStack(alignment: .leading, spacing: 6 * u) {
                HStack(alignment: .top, spacing: 10 * u) {
                    SignTitleBlock(spec: spec, isPreview: isPreview, u: u,
                                   lineLimit: spec.isWide ? 2 : 3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    AceBadgeView(logo: spec.customLogo, u: u, heightUnits: 34)
                }
                ClearancePriceRow(spec: spec, isPreview: isPreview, u: u)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                ClearanceTermsBlock(u: u)
                SignFooter(sku: spec.sku, footer: spec.footerText, u: u)
            }
            .padding(EdgeInsets(top: 8 * u, leading: 11 * u, bottom: 8 * u, trailing: 11 * u))
        }
        .padding(frameWidth)
        .overlay(Rectangle().strokeBorder(Color.aceRed, lineWidth: frameWidth))
    }
}

/// Full-bleed black banner across the top — the part that carries across the
/// aisle. Ace Red tab on the right pins down that the deal is one machine.
struct ClearanceBanner: View {
    let u: CGFloat

    var body: some View {
        HStack(spacing: 8 * u) {
            Text(ClearanceCopy.banner)
                .font(AceFont.font(size: 25 * u, weight: .black))
                .tracking(0.5 * u)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            Spacer(minLength: 0)
            Text(ClearanceCopy.kicker)
                .font(AceFont.font(size: 10 * u, weight: .black))
                .tracking(0.5 * u)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 6 * u)
                .padding(.vertical, 2.5 * u)
                .background(Rectangle().fill(Color.aceRed))
        }
        .padding(.horizontal, 10 * u)
        .padding(.vertical, 5 * u)
        .frame(maxWidth: .infinity)
        .background(Rectangle().fill(Color.black))
    }
}

/// Was/Now pricing. With `wasNowStyle` on and a was-price set, the old price
/// sits struck through beside a "NOW" pricepoint plus the dollars saved;
/// otherwise it's the pricepoint on its own.
struct ClearancePriceRow: View {
    let spec: SignSpec
    let isPreview: Bool
    let u: CGFloat

    private var wasParts: PriceFormatter.Parts? {
        guard spec.wasNowStyle else { return nil }
        return PriceFormatter.parts(from: spec.wasPriceText)
    }

    /// Whole-dollar savings, shown only when the was-price is genuinely higher.
    private var savings: String? {
        guard spec.wasNowStyle,
              let was = Double(spec.wasPriceText.replacingOccurrences(of: "$", with: "")
                                                .replacingOccurrences(of: ",", with: "")
                                                .trimmingCharacters(in: .whitespaces)),
              let now = Double(spec.priceText.replacingOccurrences(of: "$", with: "")
                                             .replacingOccurrences(of: ",", with: "")
                                             .trimmingCharacters(in: .whitespaces)),
              was - now >= 1,
              let parts = PriceFormatter.parts(from: String(format: "%.2f", was - now))
        else { return nil }
        // Reads as a price, not an accounting figure: "$120", not "$120.00".
        return parts.cents == "00" ? "$\(parts.dollars)" : "$\(parts.dollars).\(parts.cents)"
    }

    var body: some View {
        // Wide runs was/now side by side; tall stacks them, because a portrait
        // sign has height to spend and no photo to spend it on.
        if spec.isWide { wideRow } else { tallColumn }
    }

    private var wideRow: some View {
        HStack(alignment: .center, spacing: 10 * u) {
            if wasParts != nil {
                VStack(alignment: .leading, spacing: 3 * u) {
                    wasLabel
                    wasPrice
                    savingsChip
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 3 * u) {
                if wasParts != nil {
                    SaleTag(u: u, text: "NOW")
                }
                pricePoint
            }
            .layoutPriority(1)
        }
    }

    private var tallColumn: some View {
        VStack(spacing: 4 * u) {
            if wasParts != nil {
                wasLabel
                wasPrice
                SaleTag(u: u, text: "NOW")
            }
            pricePoint
            savingsChip
        }
        .frame(maxWidth: .infinity)
    }

    private var wasLabel: some View {
        Text("WAS")
            .font(AceFont.font(size: 10 * u, weight: .black))
            .tracking(0.8 * u)
            .foregroundColor(.aceCoolGray)
    }

    @ViewBuilder
    private var wasPrice: some View {
        if let was = wasParts {
            Text("$\(was.dollars).\(was.cents)")
                .font(AceFont.font(size: 24 * u, weight: .bold))
                .foregroundColor(.aceCoolGray)
                .strikethrough(true, color: .aceRed)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
        }
    }

    @ViewBuilder
    private var savingsChip: some View {
        if let savings {
            Text("YOU SAVE \(savings)")
                .font(AceFont.font(size: 11 * u, weight: .black))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 6 * u)
                .padding(.vertical, 2.5 * u)
                .background(Rectangle().fill(Color.aceRed))
        }
    }

    private var pricePoint: some View {
        PricePointChip(price: spec.priceText, unit: spec.unitSuffix, u: u,
                       placeholderWhenEmpty: isPreview)
    }
}

/// The store's clearance terms, set as small print in a boxed block so they
/// read as terms rather than as marketing.
struct ClearanceTermsBlock: View {
    let u: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 3 * u) {
            Text(ClearanceCopy.policyHeading)
                .font(AceFont.font(size: 8 * u, weight: .black))
                .tracking(0.8 * u)
                .foregroundColor(.white)
                .padding(.horizontal, 5 * u)
                .padding(.vertical, 1.5 * u)
                .background(Rectangle().fill(Color.black))
            ForEach(ClearanceCopy.policy, id: \.self) { line in
                HStack(alignment: .top, spacing: 4 * u) {
                    Rectangle()
                        .fill(Color.aceRed)
                        .frame(width: 3.5 * u, height: 3.5 * u)
                        .padding(.top, 3 * u)
                    Text(line)
                        .font(AceFont.font(size: 8.5 * u, weight: .medium))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(6 * u)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Rectangle().fill(Color.aceLightGray))
        .overlay(Rectangle().strokeBorder(Color.black, lineWidth: max(1, 0.9 * u)))
    }
}

// MARK: - Shared building blocks

/// The Ace brand mark: a custom logo from Settings if set, otherwise the
/// embedded official Ace Hardware logo (stacked two-line wordmark — the
/// preferred lockup), with a drawn badge as last resort.
struct AceBadgeView: View {
    let logo: NSImage?
    let u: CGFloat
    /// Mark height in layout units — smaller on formats where the headline,
    /// not the logo, is doing the shouting.
    var heightUnits: CGFloat = 56

    var body: some View {
        if let image = logo ?? AceBrand.logo {
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(height: heightUnits * u)
                .frame(maxWidth: heightUnits * 2.7 * u, alignment: .leading)
        } else {
            RoundedRectangle(cornerRadius: 10 * u)
                .fill(Color.aceRed)
                .frame(width: heightUnits * u, height: heightUnits * u)
                .overlay(
                    VStack(spacing: 1 * u) {
                        Text("Ace")
                            .font(.system(size: 26 * u * (heightUnits / 56), weight: .black, design: .serif))
                            .italic()
                        Text("HARDWARE")
                            .font(.system(size: 6 * u * (heightUnits / 56), weight: .bold))
                            .tracking(1.1 * u * (heightUnits / 56))
                    }
                    .foregroundColor(.white)
                )
        }
    }
}

struct SignTitleBlock: View {
    let spec: SignSpec
    let isPreview: Bool
    let u: CGFloat
    let lineLimit: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2 * u) {
            Text(spec.productName.isEmpty ? (isPreview ? "Product name" : " ") : spec.productName)
                .font(AceFont.font(size: 20 * u, weight: .bold))
                .foregroundColor(spec.productName.isEmpty ? Color.black.opacity(0.25) : .black)
                .lineLimit(lineLimit)
                .minimumScaleFactor(0.55)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            if !spec.detailLine.isEmpty {
                Text(spec.detailLine)
                    .font(AceFont.font(size: 11.5 * u, weight: .medium))
                    .foregroundColor(.aceCoolGray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
    }
}

/// Price display in the two official styles:
/// - `.plain` — big Ace-red price for everyday signs
/// - `.salePoint` — the guideline promo format: black SALE tag, white price
///   on a red chip with superscript cents and the unit under them, and a
///   black "REG. $x.xx" chip when a was-price is provided.
struct PriceBlock: View {
    enum Style {
        case plain
        case salePoint
    }

    let price: String
    let was: String
    let unit: String
    let u: CGFloat
    var alignment: HorizontalAlignment = .trailing
    var style: Style = .plain
    var placeholderWhenEmpty = false

    var body: some View {
        let hasPrice = !price.trimmingCharacters(in: .whitespaces).isEmpty
        VStack(alignment: alignment, spacing: 3 * u) {
            if style == .salePoint {
                // No orphan SALE tag on a sign with no price.
                if hasPrice || placeholderWhenEmpty {
                    SaleTag(u: u)
                        .opacity(hasPrice ? 1 : 0.35)
                }
                PricePointChip(price: price, unit: unit, u: u,
                               placeholderWhenEmpty: placeholderWhenEmpty)
                RegPriceChip(was: was, u: u)
            } else {
                plainPrice
                if !unit.isEmpty {
                    Text(unit)
                        .font(AceFont.font(size: 13 * u, weight: .medium))
                        .foregroundColor(.aceCoolGray)
                }
                RegPriceChip(was: was, u: u)
            }
        }
    }

    @ViewBuilder
    private var plainPrice: some View {
        if let parts = PriceFormatter.parts(from: price) {
            HStack(alignment: .top, spacing: 1 * u) {
                Text("$")
                    .font(AceFont.font(size: 28 * u, weight: .black))
                    .padding(.top, 8 * u)
                Text(parts.dollars)
                    .font(AceFont.font(size: 84 * u, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                Text(parts.cents)
                    .font(AceFont.font(size: 30 * u, weight: .black))
                    .padding(.top, 8 * u)
            }
            .foregroundColor(.aceRed)
        } else if !price.trimmingCharacters(in: .whitespaces).isEmpty {
            // Free-form price text ("2 for $5", "25% off"…)
            Text(price)
                .font(AceFont.font(size: 40 * u, weight: .black))
                .foregroundColor(.aceRed)
                .lineLimit(2)
                .minimumScaleFactor(0.4)
                .multilineTextAlignment(.center)
        } else if placeholderWhenEmpty {
            Text("$ —.—")
                .font(AceFont.font(size: 50 * u, weight: .black))
                .foregroundColor(Color.aceRed.opacity(0.2))
        }
    }
}

/// The official Ace pricepoint: white price on a solid Ace-red chip, dollar
/// sign and cents superscript, unit ("each", "/ft"…) tucked under the cents.
struct PricePointChip: View {
    let price: String
    let unit: String
    let u: CGFloat
    var placeholderWhenEmpty = false

    var body: some View {
        let trimmed = price.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty || placeholderWhenEmpty {
            chipContent(for: trimmed.isEmpty ? "0.00" : trimmed)
                .foregroundColor(.white)
                .padding(.horizontal, 10 * u)
                .padding(.vertical, 6 * u)
                .background(Rectangle().fill(Color.aceRed))
                .opacity(trimmed.isEmpty ? 0.35 : 1)
        }
    }

    @ViewBuilder
    private func chipContent(for text: String) -> some View {
        if let parts = PriceFormatter.parts(from: text) {
            HStack(alignment: .top, spacing: 1.5 * u) {
                Text("$")
                    .font(AceFont.font(size: 26 * u, weight: .black))
                    .padding(.top, 6 * u)
                Text(parts.dollars)
                    .font(AceFont.font(size: 68 * u, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                VStack(alignment: .leading, spacing: 0) {
                    Text(parts.cents)
                        .font(AceFont.font(size: 26 * u, weight: .black))
                    if !unit.isEmpty {
                        Text(unit)
                            .font(AceFont.font(size: 9.5 * u, weight: .medium))
                    }
                }
                .padding(.top, 6 * u)
            }
        } else {
            Text(text)
                .font(AceFont.font(size: 34 * u, weight: .black))
                .lineLimit(2)
                .minimumScaleFactor(0.4)
                .multilineTextAlignment(.center)
        }
    }
}

/// Black "SALE" tag that sits above the pricepoint (guidelines p73).
struct SaleTag: View {
    let u: CGFloat
    var text = "SALE"

    var body: some View {
        Text(text)
            .font(AceFont.font(size: 15 * u, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 8 * u)
            .padding(.vertical, 2.5 * u)
            .background(Rectangle().fill(Color.black))
    }
}

/// Black "REG. $x.xx" chip with superscript cents (guidelines p73).
/// Renders nothing when no was-price is set.
struct RegPriceChip: View {
    let was: String
    let u: CGFloat

    var body: some View {
        if let parts = PriceFormatter.parts(from: was) {
            HStack(alignment: .top, spacing: 0.5 * u) {
                Text("REG. $\(parts.dollars)")
                    .font(AceFont.font(size: 10.5 * u, weight: .bold))
                Text(parts.cents)
                    .font(AceFont.font(size: 7 * u, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6 * u)
            .padding(.vertical, 2.5 * u)
            .background(Rectangle().fill(Color.black))
        }
    }
}

struct ProductPhotoView: View {
    let image: NSImage?
    let showPlaceholder: Bool
    let u: CGFloat

    var body: some View {
        if let image {
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
        } else if showPlaceholder {
            RoundedRectangle(cornerRadius: 6 * u)
                .strokeBorder(Color.black.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                .overlay(
                    VStack(spacing: 4 * u) {
                        Image(systemName: "photo")
                            .font(.system(size: 22 * u))
                        Text("Photo appears here")
                            .font(.system(size: 10 * u))
                    }
                    .foregroundColor(Color.black.opacity(0.3))
                )
        } else {
            Color.clear
        }
    }
}

struct SignFooter: View {
    let sku: String
    let footer: String?
    let u: CGFloat

    var body: some View {
        if !sku.isEmpty || (footer?.isEmpty == false) {
            VStack(spacing: 4 * u) {
                Rectangle()
                    .fill(Color.aceHairline)
                    .frame(height: max(1, u))
                HStack(spacing: 8 * u) {
                    if !sku.isEmpty {
                        Text("SKU \(sku)")
                    }
                    Spacer(minLength: 0)
                    if let footer, !footer.isEmpty {
                        Text(footer)
                    }
                }
                .font(AceFont.font(size: 9.5 * u, weight: .regular))
                .foregroundColor(.aceCoolGray)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
        }
    }
}
