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
        
    }
}
