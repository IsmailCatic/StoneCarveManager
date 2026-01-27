using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using StoneCarveManager.Services.IServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Services
{
    public class AzureBlobFileService : IFileService
    {
        private readonly BlobServiceClient _blobServiceClient;
        private readonly IConfiguration _configuration;

        public AzureBlobFileService(IConfiguration configuration)
        {
            _configuration = configuration;
            var connectionString = _configuration.GetSection("AzureBlobStorage:ConnectionString").Value;
            _blobServiceClient = new BlobServiceClient(connectionString);
        }

        public async Task<string> UploadAsync(IFormFile file, string containerName, string? fileName = null, CancellationToken cancellationToken = default)
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            await containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob, cancellationToken: cancellationToken);

            var name = fileName ?? $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
            var blobClient = containerClient.GetBlobClient(name);

            using (var stream = file.OpenReadStream())
            {
                await blobClient.UploadAsync(stream, overwrite: true, cancellationToken: cancellationToken);
            }

            return blobClient.Uri.AbsoluteUri;
        }

        public async Task DeleteAsync(string blobUrl, string containerName, CancellationToken cancellationToken = default)
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);

            var blobName = GetBlobNameFromUrl(blobUrl);
            var blobClient = containerClient.GetBlobClient(blobName);

            await blobClient.DeleteIfExistsAsync(cancellationToken: cancellationToken);
        }

        public async Task<Stream> DownloadAsync(string blobUrl, string containerName, CancellationToken cancellationToken = default)
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
            var blobName = GetBlobNameFromUrl(blobUrl);

            var blobClient = containerClient.GetBlobClient(blobName);
            var downloadInfo = await blobClient.DownloadAsync(cancellationToken);

            // NOTE: Stream moraš dispose-ati nakon korištenja!
            return downloadInfo.Value.Content;
        }

        // Helper method to extract blob name from URL
        private string GetBlobNameFromUrl(string url)
        {
            // Example: .../containerName/filename.jpg
            var uri = new Uri(url);
            return uri.Segments[^1];
        }
    }
}
