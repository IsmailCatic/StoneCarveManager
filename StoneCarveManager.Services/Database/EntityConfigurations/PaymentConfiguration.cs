using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using StoneCarveManager.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Database.EntityConfigurations
{
    public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
    {
        public void Configure(EntityTypeBuilder<Payment> builder)
        {
            builder.ToTable("Payments");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.Amount)
                .IsRequired()
                .HasColumnType("decimal(18,2)");

            builder.Property(x => x.RefundAmount)
                .IsRequired(false)
                .HasColumnType("decimal(18,2)");

            builder.Property(x => x.RefundReason)
                .HasMaxLength(500);

            builder.Property(x => x.RefundedAt)
                .IsRequired(false);

            builder.Property(x => x.Method)
                .IsRequired()
                .HasConversion<string>()
                .HasMaxLength(50);

            builder.Property(x => x.Status)
                .IsRequired()
                .HasConversion<string>()
                .HasMaxLength(50);

            builder.Property(x => x.TransactionId)
                .HasMaxLength(100);

            builder.Property(x => x.FailureReason)
                .HasMaxLength(500);

            builder.Property(x => x.CreatedAt)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            // Relationships
            builder.HasOne(x => x.Order)
                .WithOne(o => o.Payment)
                .HasForeignKey<Payment>(x => x.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            // Indexes
            builder.HasIndex(x => x.OrderId).IsUnique();
            builder.HasIndex(x => x.TransactionId);
            builder.HasIndex(x => x.Status);
            builder.HasIndex(x => x.CreatedAt);

            // Check constraints
            builder.ToTable(t => t.HasCheckConstraint("CK_Payment_Amount", "[Amount] > 0"));
            builder.ToTable(t => t.HasCheckConstraint("CK_Payment_RefundAmount", "[RefundAmount] IS NULL OR ([RefundAmount] >= 0 AND [RefundAmount] <= [Amount])"));
        }
    }
}
