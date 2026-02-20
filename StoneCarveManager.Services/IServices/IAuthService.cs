using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface IAuthService
    {
        Task<TokenDTO> Login(LoginRequest model);
        Task<TokenDTO> Register(RegisterRequest model);
        
        // ✅ Password reset methods with verification code
        Task<bool> RequestPasswordResetAsync(string email);
        Task<bool> ResetPasswordAsync(string email, string verificationCode, string newPassword);
    }
}
