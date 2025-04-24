using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class CitaonicaUpsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Naziv čitaonice ne može imati manje od dva karaktera")]
        [MaxLength(25, ErrorMessage = "Naziv čitaonice ne može imati više od 25 karaktera")]
        public string Naziv { get; set; } 
    }
}
