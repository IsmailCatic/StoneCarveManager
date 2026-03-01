using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Responses;
using System.Collections.Generic;
using System.Linq;

namespace StoneCarveManagerWebAPI.Controllers
{
    /// <summary>
    /// Static lookup data for dropdowns (countries, cities).
    /// No database table needed — data is maintained here as the business operates regionally.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class LookupController : ControllerBase
    {
        private static readonly List<CountryResponse> _countries = new()
        {
            new() { Code = "BA", Name = "Bosnia and Herzegovina" },
            new() { Code = "HR", Name = "Croatia" },
            new() { Code = "RS", Name = "Serbia" },
            new() { Code = "ME", Name = "Montenegro" },
            new() { Code = "SI", Name = "Slovenia" },
            new() { Code = "MK", Name = "North Macedonia" },
            new() { Code = "AT", Name = "Austria" },
            new() { Code = "DE", Name = "Germany" },
            new() { Code = "CH", Name = "Switzerland" },
            new() { Code = "IT", Name = "Italy" },
            new() { Code = "FR", Name = "France" },
            new() { Code = "NL", Name = "Netherlands" },
            new() { Code = "BE", Name = "Belgium" },
            new() { Code = "SE", Name = "Sweden" },
            new() { Code = "NO", Name = "Norway" },
            new() { Code = "DK", Name = "Denmark" },
            new() { Code = "PL", Name = "Poland" },
            new() { Code = "CZ", Name = "Czech Republic" },
            new() { Code = "GB", Name = "United Kingdom" },
            new() { Code = "US", Name = "United States" },
            new() { Code = "CA", Name = "Canada" },
            new() { Code = "AU", Name = "Australia" },
        };

        // Cities grouped by country code.
        // Focus on BiH and neighbouring countries as the primary service area.
        private static readonly List<CityResponse> _cities = new()
        {
            // Bosnia and Herzegovina
            new() { Name = "Sarajevo",      CountryCode = "BA" },
            new() { Name = "Mostar",        CountryCode = "BA" },
            new() { Name = "Banja Luka",    CountryCode = "BA" },
            new() { Name = "Tuzla",         CountryCode = "BA" },
            new() { Name = "Zenica",        CountryCode = "BA" },
            new() { Name = "Biha?",         CountryCode = "BA" },
            new() { Name = "Bijeljina",     CountryCode = "BA" },
            new() { Name = "Br?ko",         CountryCode = "BA" },
            new() { Name = "Doboj",         CountryCode = "BA" },
            new() { Name = "Cazin",         CountryCode = "BA" },
            new() { Name = "Travnik",       CountryCode = "BA" },
            new() { Name = "Konjic",        CountryCode = "BA" },
            new() { Name = "Livno",         CountryCode = "BA" },
            new() { Name = "Trebinje",      CountryCode = "BA" },
            new() { Name = "Široki Brijeg", CountryCode = "BA" },
            new() { Name = "?apljina",      CountryCode = "BA" },
            new() { Name = "Stolac",        CountryCode = "BA" },
            new() { Name = "Neum",          CountryCode = "BA" },

            // Croatia
            new() { Name = "Zagreb",        CountryCode = "HR" },
            new() { Name = "Split",         CountryCode = "HR" },
            new() { Name = "Rijeka",        CountryCode = "HR" },
            new() { Name = "Osijek",        CountryCode = "HR" },
            new() { Name = "Zadar",         CountryCode = "HR" },
            new() { Name = "Dubrovnik",     CountryCode = "HR" },

            // Serbia
            new() { Name = "Beograd",       CountryCode = "RS" },
            new() { Name = "Novi Sad",      CountryCode = "RS" },
            new() { Name = "Niš",           CountryCode = "RS" },
            new() { Name = "Kragujevac",    CountryCode = "RS" },

            // Montenegro
            new() { Name = "Podgorica",     CountryCode = "ME" },
            new() { Name = "Nikši?",        CountryCode = "ME" },
            new() { Name = "Budva",         CountryCode = "ME" },

            // Slovenia
            new() { Name = "Ljubljana",     CountryCode = "SI" },
            new() { Name = "Maribor",       CountryCode = "SI" },

            // Austria
            new() { Name = "Wien",          CountryCode = "AT" },
            new() { Name = "Graz",          CountryCode = "AT" },
            new() { Name = "Linz",          CountryCode = "AT" },

            // Germany
            new() { Name = "Berlin",        CountryCode = "DE" },
            new() { Name = "München",       CountryCode = "DE" },
            new() { Name = "Frankfurt",     CountryCode = "DE" },
            new() { Name = "Hamburg",       CountryCode = "DE" },
            new() { Name = "Stuttgart",     CountryCode = "DE" },

            // Switzerland
            new() { Name = "Zürich",        CountryCode = "CH" },
            new() { Name = "Bern",          CountryCode = "CH" },
            new() { Name = "Genf",          CountryCode = "CH" },
        };

        /// <summary>
        /// Returns all supported countries for delivery address dropdowns.
        /// </summary>
        [HttpGet("countries")]
        public ActionResult<List<CountryResponse>> GetCountries()
        {
            return Ok(_countries.OrderBy(c => c.Name).ToList());
        }

        /// <summary>
        /// Returns cities. Optionally filtered by countryCode (e.g. ?countryCode=BA).
        /// </summary>
        [HttpGet("cities")]
        public ActionResult<List<CityResponse>> GetCities([FromQuery] string? countryCode = null)
        {
            var result = string.IsNullOrWhiteSpace(countryCode)
                ? _cities
                : _cities.Where(c => c.CountryCode.Equals(countryCode.Trim(), System.StringComparison.OrdinalIgnoreCase)).ToList();

            return Ok(result.OrderBy(c => c.Name).ToList());
        }
    }
}
