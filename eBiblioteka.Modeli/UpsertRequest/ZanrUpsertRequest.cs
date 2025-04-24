using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class ZanrUpsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Ime žanra ne može biti kraće od 2 karaktera")]
        [MaxLength(50, ErrorMessage = "Ime žanra ne može biti duže od 50 karaktera")]
        public string Naziv { get; set; } = null!;
    }
}
