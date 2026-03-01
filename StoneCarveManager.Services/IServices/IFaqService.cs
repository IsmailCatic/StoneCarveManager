using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface IFaqService
        : ICRUDService<FaqResponse, FaqSearchObject, FaqInsertRequest, FaqUpdateRequest>
    {
        /// <summary>
        /// Increments the ViewCount for the given FAQ and returns the updated entry.
        /// </summary>
        Task<FaqResponse?> TrackViewAsync(int id, CancellationToken cancellationToken = default);
    }
}
