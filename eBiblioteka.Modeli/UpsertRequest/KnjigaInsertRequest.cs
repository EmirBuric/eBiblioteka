using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class KnjigaInsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Naziv knjige ne može imati manje od dva karaktera")]
        [MaxLength(50, ErrorMessage = "Naziv knjige ne može imati više od 50 karaktera")]
        public string Naziv { get; set; } 

        public string? KratkiOpis { get; set; }

        [Required(ErrorMessage = "Ovo polje ne može biti prazno")]
        [Range(1, 2025, ErrorMessage = "Godina izdanja može biti od 0 do 2025")]
        public int GodinaIzdanja { get; set; }

        //public byte[]? Slika { get; set; }

        public int? ZanrId { get; set; }

        [Required(ErrorMessage = "Ovo polje ne može biti prazno")]
        [Range(1, int.MaxValue, ErrorMessage = "Količina mora biti najmanje 1")]
        public int Kolicina { get; set; }
       
        public List<int> Autori { get; set; }
    }
}
