using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Responses
{
    public class TokenDTO
    {
        public required string Token { get; set; }
        public int UserId { get; set; }
        public DateTime ValidTo { get; set; }
        
        // ✅ Promijenjeno sa "Role" na "Roles" (plural) radi konzistencije sa Flutter-om
        public string[] Roles { get; set; } = Array.Empty<string>();
    }
}
