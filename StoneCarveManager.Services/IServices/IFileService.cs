using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface IFileService
    {
        Task<string> UploadAsync(IFormFile file, string containerName, string? fileName = null, CancellationToken cancellationToken = default);
        Task DeleteAsync(string blobUrl, string containerName, CancellationToken cancellationToken = default);
        Task<Stream> DownloadAsync(string blobUrl, string containerName, CancellationToken cancellationToken = default);
    }
}
