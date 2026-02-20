namespace StoneCarveManager.Model.Requests
{
    public class PasswordResetRequestRequest
    {
        public string Email { get; set; } = string.Empty;
    }

    public class PasswordResetConfirmRequest
    {
        public string Email { get; set; } = string.Empty;
        public string VerificationCode { get; set; } = string.Empty;  // ? 6-digit code
        public string NewPassword { get; set; } = string.Empty;
    }
}
