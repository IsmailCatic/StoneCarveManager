namespace StoneCarveManager.Services.IServices
{
    /// <summary>
    /// Service for accessing currently authenticated user information
    /// </summary>
    public interface ICurrentUserService
    {
        /// <summary>
        /// Gets the ID of the currently authenticated user
        /// </summary>
        /// <returns>User ID</returns>
        /// <exception cref="UnauthorizedAccessException">Thrown when user is not authenticated</exception>
        int GetUserId();
        int? TryGetUserId();
        string? GetUserEmail();
        bool IsAuthenticated { get; }
    }
}
