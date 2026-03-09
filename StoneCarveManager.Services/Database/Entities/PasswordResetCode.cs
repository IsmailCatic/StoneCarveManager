using System;
using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Services.Database.Entities
{
    public class PasswordResetCode
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(256)]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(6)]
        public string Code { get; set; } = string.Empty;

        public DateTime ExpiresAt { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public bool IsUsed { get; set; } = false;
    }
}