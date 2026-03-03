using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Services.Database.Entities;
using System;

namespace StoneCarveManager.Services.Database.DataSeeds
{
    internal static class FaqSeed
    {
        public static void Seed(ModelBuilder builder)
        {
            builder.Entity<Faq>().HasData(
                // Ordering
                new Faq
                {
                    Id = 1,
                    Question = "How do I place a custom order?",
                    Answer = "Browse our Custom Carvings catalogue and tap 'Request Custom Order'. Describe your idea, upload any reference images or sketches, and submit. One of our craftsmen will contact you within 24 hours to discuss details, provide a quote, and agree on a timeline. No payment is required until you approve the final design.",
                    Category = "Ordering",
                    DisplayOrder = 0,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Faq
                {
                    Id = 2,
                    Question = "Can I modify an order after it has been placed?",
                    Answer = "Modifications can be accommodated if the order is still in 'Pending' status. Once carving has begun ('Processing' status), structural changes are no longer possible, though minor adjustments to finish or engraving may still be feasible. Contact us immediately through the app's order detail screen and we will do our best to help.",
                    Category = "Ordering",
                    DisplayOrder = 1,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Faq
                {
                    Id = 3,
                    Question = "How long does production take?",
                    Answer = "Production times vary by product. Simple pieces such as text engravings or small bird baths take 5–10 days. Medium-complexity items like wall fountains or garden benches take 10–15 days. Large architectural elements and custom commissions typically require 3–6 weeks. Estimated completion dates are displayed on each product page and confirmed in your order confirmation.",
                    Category = "Ordering",
                    DisplayOrder = 2,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },

                // Payments
                new Faq
                {
                    Id = 4,
                    Question = "What payment methods do you accept?",
                    Answer = "We accept credit and debit cards via Stripe (Visa, Mastercard, Amex), bank transfers, and cash on collection. All card payments are processed securely through Stripe and we never store your card details. For large custom orders over €2,000 we require a 30% deposit at the time of order confirmation.",
                    Category = "Payments",
                    DisplayOrder = 0,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Faq
                {
                    Id = 5,
                    Question = "Is my payment information secure?",
                    Answer = "Yes. All card transactions are processed by Stripe, a PCI-DSS Level 1 certified payment provider. We never see or store your full card number. Payments in the app are protected by TLS encryption.",
                    Category = "Payments",
                    DisplayOrder = 1,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },

                // Delivery & Collection
                new Faq
                {
                    Id = 6,
                    Question = "Do you offer delivery?",
                    Answer = "Yes. We deliver within a 150 km radius of our workshop. Delivery fees are calculated at checkout based on distance and the weight of your order. For very large or fragile pieces, delivery is carried out by our own team using a padded van — we do not use third-party couriers for stone items. Collection from our workshop is always free.",
                    Category = "Delivery",
                    DisplayOrder = 0,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Faq
                {
                    Id = 7,
                    Question = "How is my piece packaged for delivery?",
                    Answer = "All stone pieces are wrapped in thick moving blankets and secured with ratchet straps on a custom-built wooden pallet or in a reinforced crate for fragile items. We take full responsibility for the piece until it is safely in your hands. On delivery, please inspect the item in the presence of our driver and note any damage on the delivery receipt before signing.",
                    Category = "Delivery",
                    DisplayOrder = 1,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },

                // Materials
                new Faq
                {
                    Id = 8,
                    Question = "How do I care for my outdoor stone sculpture?",
                    Answer = "We recommend an annual clean with warm water and a soft brush, followed by the application of a breathable silicone-based stone sealer. Avoid acidic cleaners (vinegar, bleach), pressure washing at close range, and salt-based de-icers near the piece in winter. For water features, drain and disconnect pumps before the first frost each autumn.",
                    Category = "Materials",
                    DisplayOrder = 0,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },
                new Faq
                {
                    Id = 9,
                    Question = "Which stone is best for outdoor use?",
                    Answer = "Black granite is the most durable choice for all-weather outdoor installation, being frost-resistant and virtually impervious to staining. Limestone and travertine are popular for gardens and age beautifully, but require periodic sealing. White marble is best kept indoors or in sheltered outdoor settings, as it is more susceptible to acid rain and surface etching over time.",
                    Category = "Materials",
                    DisplayOrder = 1,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                },

                // Returns
                new Faq
                {
                    Id = 10,
                    Question = "What is your returns and refunds policy?",
                    Answer = "Stock items in undamaged condition may be returned within 14 days of delivery for a full refund, minus the delivery cost. Because custom-made pieces are produced to your unique specifications, they are non-refundable unless they arrive damaged or significantly differ from the agreed design. If your item arrives damaged, please photograph it immediately and contact us within 48 hours — we will arrange a replacement or refund as appropriate.",
                    Category = "Returns",
                    DisplayOrder = 0,
                    IsActive = true,
                    CreatedAt = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                }
            );
        }
    }
}
