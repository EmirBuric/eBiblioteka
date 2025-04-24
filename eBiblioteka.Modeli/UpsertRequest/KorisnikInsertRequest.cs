using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class KorisnikInsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Ime korisnika ne može biti kraće od 2 karaktera")]
        [MaxLength(50, ErrorMessage = "Ime korisnika ne može biti duže od 50 karaktera")]
        public string Ime { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Prezime korisnika ne može biti kraće od 2 karaktera")]
        [MaxLength(50, ErrorMessage = "Prezime korisnika ne može biti duže od 50 karaktera")]
        public string Prezime { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [EmailAddress(ErrorMessage = "Email Mora biti u validnom formatu")]
        public string Email { get; set; }

        [RegularExpression(@"^(?:\+387)[\s-]?[6][0-9][\s-]?[0-9]{3}[\s-]?[0-9]{3}$",
        ErrorMessage = "Telefon mora biti u formatu +3876XXXXXXXX")]
        public string Telefon { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Korisničko ime ne može biti kraće od 2 karaktera")]
        [MaxLength(50, ErrorMessage = "Korisničko ime ne može biti duže od 50 karaktera")]
        public string KorisnickoIme { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [Compare("LozinkaPotvrda", ErrorMessage = "Lozinke nisu iste")]
        public string Lozinka { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [Compare("Lozinka", ErrorMessage = "Lozinke nisu iste")]
        public string LozinkaPotvrda { get; set; }

        public List<int> Uloge { get; set; }
    }
}
