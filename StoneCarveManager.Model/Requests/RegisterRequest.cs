using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Requests
{
    public class RegisterRequest
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string? ProfilePicture { get; set; }
        public DateOnly DateOfBirth { get; set; }
        //public int CountryId { get; set; }
        //public int CityId { get; set; }
        //public int GenderId { get; set; }
        //public List<SecurityQuestionAnswerRequest>? SecurityQuestions { get; set; }

        [JsonIgnore]
        public byte[]? ProfilePictureBytes =>
        string.IsNullOrEmpty(ProfilePicture) ? null : Convert.FromBase64String(ProfilePicture.Split(',')[1]);

    }

    //public class RegisterRequest
    //{
    //    public string FirstName { get; set; }
    //    public string LastName { get; set; }
    //    public string Email { get; set; }
    //    public string Password { get; set; }
    //    public string? PhoneNumber { get; set; }
    //    public string? ProfileImageUrl { get; set; }
    //}
}
