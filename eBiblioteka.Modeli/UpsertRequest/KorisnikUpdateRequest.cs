using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class KorisnikUpdateRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Ime korisnika ne može biti kraće od 2 karaktera")]
        [MaxLength(50, ErrorMessage = "Ime korisnika ne može biti duže od 50 karaktera")]
        public string Ime { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Prezime korisnika ne može biti kraće od 2 karaktera")]
        [MaxLength(50, ErrorMessage = "Prezime korisnika ne može biti duže od 50 karaktera")]
        public string Prezime { get; set; } 

        public string? Telefon { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [Compare("LozinkaPotvrda", ErrorMessage = "Lozinke nisu iste")]
        public string Lozinka { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [Compare("Lozinka", ErrorMessage = "Lozinke nisu iste")]
        public string LozinkaPotvrda { get; set; } 
    }
}
