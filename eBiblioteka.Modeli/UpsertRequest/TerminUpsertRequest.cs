using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class TerminUpsertRequest
    {
        [Required(ErrorMessage = "Ovo polje ne može biti prazno")]
        public DateOnly Datum { get; set; }

        [Required(ErrorMessage = "Ovo polje ne može biti prazno")]
        public TimeOnly Start { get; set; }

        [Required(ErrorMessage = "Ovo polje ne može biti prazno")]
        public TimeOnly Kraj { get; set; }

        [Required(ErrorMessage = "Ovo polje ne može biti prazno")]
        public int CitaonicaId { get; set; }
    }
}
