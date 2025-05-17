using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class KnjigaUpdateRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Naziv knjige ne može imati manje od dva karaktera")]
        [MaxLength(50, ErrorMessage = "Naziv knjige ne može imati više od 50 karaktera")]
        public string Naziv { get; set; }

        public string? KratkiOpis { get; set; }

        public int? GodinaIzdanja { get; set; }

        public byte[]? Slika { get; set; }

        public int ZanrId { get; set; }

        [Required(ErrorMessage = "Ovo polje ne može biti prazno")]
        [Range(0, int.MaxValue, ErrorMessage = "Količina mora biti najmanje 0")]
        public int Kolicina { get; set; }

        public List<int> Autori { get; set; }
    }
}
