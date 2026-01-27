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
    public class OrderConfiguration : IEntityTypeConfiguration<Order>
    {
        public void Configure(EntityTypeBuilder<Order> builder)
        {
            builder.ToTable("Orders");

            builder.HasKey(x => x.Id);

            builder.Property(x => x.OrderNumber)
                .IsRequired()
                .HasMaxLength(50);

            builder.Property(x => x.Status)
                .IsRequired()
                .HasConversion<string>()
                .HasMaxLength(50);

            builder.Property(x => x.TotalAmount)
                .IsRequired()
                .HasColumnType("decimal(18,2)");

            builder.Property(x => x.CustomerNotes)
                .HasMaxLength(2000);

            builder.Property(x => x.AdminNotes)
                .HasMaxLength(2000);

            builder.Property(x => x.AttachmentUrl)
                .HasMaxLength(500);

            builder.Property(x => x.DeliveryAddress)
                .HasMaxLength(500);

            builder.Property(x => x.DeliveryCity)
                .HasMaxLength(100);

            builder.Property(x => x.DeliveryZipCode)
                .HasMaxLength(20);

            builder.Property(x => x.OrderDate)
                .IsRequired()
                .HasDefaultValueSql("GETUTCDATE()");

            // Relationships
            builder.HasOne(x => x.User)
                .WithMany()
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(x => x.AssignedEmployee)
                .WithMany()
                .HasForeignKey(x => x.AssignedEmployeeId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.HasMany(x => x.OrderItems)
                .WithOne(oi => oi.Order)
                .HasForeignKey(oi => oi.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(x => x.StatusHistory)
                .WithOne(sh => sh.Order)
                .HasForeignKey(sh => sh.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(x => x.ProgressImages)
                .WithOne(pi => pi.Order)
                .HasForeignKey(pi => pi.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(x => x.Payment)
                .WithOne(p => p.Order)
                .HasForeignKey<Payment>(p => p.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(x => x.Review)
                .WithOne(r => r.Order)
                .HasForeignKey<ProductReview>(r => r.OrderId)
                .OnDelete(DeleteBehavior.SetNull);

            // Indexes
            builder.HasIndex(x => x.OrderNumber).IsUnique();
            builder.HasIndex(x => x.UserId);
            builder.HasIndex(x => x.AssignedEmployeeId);
            builder.HasIndex(x => x.Status);
            builder.HasIndex(x => x.OrderDate);
        }
    }
}
