using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class ClanarinaUpsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        public string StatusClanarine { get; set; }

        [Required(ErrorMessage = "Ovo polje ne može biti prazno")]
        public DateTime DatumUplate { get; set; }

        public int? KorisnikId { get; set; }

        public int? TipClanarineId { get; set; }
    }
}
