namespace StoneCarveManager.EmailService
{
    // Model klasa za registraciju korisnika
    public class UserRegistrationMessage
    {
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? Password { get; set; }
        public int Role { get; set; }
        public string? KorisnickoIme { get; set; }
    }

    // ? Model klasa za password reset sa verification code
    public class PasswordResetMessage
    {
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string VerificationCode { get; set; } = string.Empty;  // ? 6-digit code
        public string ResetToken { get; set; } = string.Empty;        // ? Hidden token (for backend validation)
        public DateTime ExpiresAt { get; set; }
    }
}
