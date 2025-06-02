using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Interfaces
{
    public interface ITerminServis: ICRUDServis<TerminDTO,TerminSearchObject,TerminUpsertRequest,TerminUpsertRequest>
    {
        public Task GenerisiTermine();
        public Task Rezervisi(RezervisiTerminRequest req);
        public Task Otkazi(int terminId);
        public Task ProvjeriJeLiProsao();

    }
}
