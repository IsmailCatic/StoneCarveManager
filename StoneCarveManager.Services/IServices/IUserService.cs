using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static StoneCarveManager.Model.Requests.UserRequests;

namespace StoneCarveManager.Services.IServices
{
    public interface IUserService
    {
        Task<PagedResult<UserDTO>> GetAsync(UserSearchObject search, CancellationToken cancellationToken);
        Task<UserDTO?> GetByIdAsync(int id, CancellationToken cancellationToken);
        Task<UserDTO?> GetByEmailAsync(string email, CancellationToken cancellationToken);
        Task<UserDTO?> GetByFirstNameAsync(string firstName, CancellationToken cancellationToken);
        Task<UserDTO> AddAsync(UserInsertRequest insertRequest, CancellationToken cancellationToken);
        Task<UserDTO> UpdateAsync(int id, UserUpdateRequest updateRequest, CancellationToken cancellationToken);
        Task<bool> DeleteAsync(int id, CancellationToken cancellationToken);
        Task<List<UserDTO>> GetByUsernamesAsync(List<string> usernames, CancellationToken cancellationToken);
    }
}
