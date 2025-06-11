using eBiblioteka.Modeli.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Recommender
{
    public interface IRecommenderServis
    {
        public List<KnjigaDTO> PreporuciKnjige(int korisnikId);

    }
}
